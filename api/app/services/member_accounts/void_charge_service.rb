module MemberAccounts
  class VoidChargeService < ApplicationService
    attr_accessor :organization, :user, :charge_id, :reason

    validates :organization, :user, :charge_id, presence: true

    def call
      return validation_failure(self) unless valid?

      charge = find_charge
      return failure(['Charge not found']) unless charge
      return failure(['Charge cannot be voided']) unless charge.voidable?

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        charge.update!(
          status: 'voided',
          voided_at: Time.current,
          notes: [charge.notes, "Voided by #{user.full_name}: #{reason}"].compact.join("\n")
        )

        broadcast_charge_voided(charge)

        success(
          charge: charge,
          membership: charge.membership.reload,
          new_balance_cents: charge.membership.account_balance_cents
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to void charge: #{e.message}"])
    end

    private

    def find_charge
      organization.member_account_charges.find_by(id: charge_id)
    end

    def broadcast_charge_voided(charge)
      ActionCable.server.broadcast(
        "member_accounts_#{organization.id}",
        {
          type: 'charge.voided',
          charge: {
            id: charge.id,
            member_name: charge.member_name,
            amount_cents: charge.amount_cents,
            new_balance_cents: charge.membership.account_balance_cents
          },
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end
