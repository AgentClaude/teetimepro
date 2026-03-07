module MemberAccounts
  class ChargeAccountService < ApplicationService
    attr_accessor :organization, :user, :membership_id, :amount_cents, :charge_type,
                  :description, :notes, :fnb_tab_id, :booking_id

    validates :organization, :user, :membership_id, :amount_cents, :charge_type, :description, presence: true
    validates :amount_cents, numericality: { greater_than: 0 }, if: :amount_cents

    def call
      return validation_failure(self) unless valid?

      membership = find_membership
      return failure(['Membership not found']) unless membership
      return failure(['Membership is not active']) unless membership.active?

      authorize_org_access!(user, organization)

      unless membership.can_charge?(amount_cents)
        remaining = membership.available_credit_cents
        return failure(["Charge exceeds credit limit. Available credit: $#{remaining / 100.0}"])
      end

      ActiveRecord::Base.transaction do
        charge = MemberAccountCharge.create!(
          organization: organization,
          membership: membership,
          charged_by: user,
          fnb_tab_id: fnb_tab_id,
          booking_id: booking_id,
          charge_type: charge_type,
          status: 'posted',
          amount_cents: amount_cents,
          description: description,
          notes: notes,
          posted_at: Time.current
        )

        broadcast_charge_created(charge)

        success(
          charge: charge,
          membership: membership.reload,
          new_balance_cents: membership.account_balance_cents
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to create charge: #{e.message}"])
    end

    private

    def find_membership
      organization.memberships.active.find_by(id: membership_id)
    end

    def broadcast_charge_created(charge)
      ActionCable.server.broadcast(
        "member_accounts_#{organization.id}",
        {
          type: 'charge.created',
          charge: {
            id: charge.id,
            member_name: charge.member_name,
            amount_cents: charge.amount_cents,
            charge_type: charge.charge_type,
            description: charge.description,
            new_balance_cents: charge.membership.account_balance_cents
          },
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
