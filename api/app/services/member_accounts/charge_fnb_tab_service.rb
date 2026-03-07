module MemberAccounts
  # Convenience service to charge an F&B tab to a member's account
  # Closes the tab and creates a member charge in one transaction
  class ChargeFnbTabService < ApplicationService
    attr_accessor :organization, :user, :tab_id, :membership_id, :notes

    validates :organization, :user, :tab_id, :membership_id, presence: true

    def call
      return validation_failure(self) unless valid?

      tab = find_tab
      return failure(['Tab not found']) unless tab
      return failure(['Tab is already closed']) unless tab.open?
      return failure(['Tab has no items']) if tab.fnb_tab_items.empty?

      membership = find_membership
      return failure(['Membership not found']) unless membership
      return failure(['Membership is not active']) unless membership.active?

      authorize_org_access!(user, organization)

      amount_cents = tab.fnb_tab_items.sum { |item| item.quantity * item.unit_price_cents }

      unless membership.can_charge?(amount_cents)
        return failure(["Charge of $#{amount_cents / 100.0} exceeds available credit of $#{membership.available_credit_cents / 100.0}"])
      end

      ActiveRecord::Base.transaction do
        # Close the tab
        tab.update!(
          status: 'closed',
          total_cents: amount_cents,
          closed_at: Time.current
        )

        # Create the member charge
        charge = MemberAccountCharge.create!(
          organization: organization,
          membership: membership,
          charged_by: user,
          fnb_tab: tab,
          charge_type: 'fnb',
          status: 'posted',
          amount_cents: amount_cents,
          description: "F&B Tab - #{tab.golfer_name} (#{tab.item_count} items)",
          notes: notes,
          posted_at: Time.current
        )

        success(
          charge: charge,
          fnb_tab: tab,
          membership: membership.reload,
          new_balance_cents: membership.account_balance_cents
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to charge tab to member account: #{e.message}"])
    end

    private

    def find_tab
      organization.fnb_tabs.find_by(id: tab_id)
    end

    def find_membership
      organization.memberships.active.find_by(id: membership_id)
    end
  end
end
