module Mutations
  class VoidMemberCharge < BaseMutation
    argument :charge_id, ID, required: true
    argument :reason, String, required: false

    field :charge, Types::MemberAccountChargeType, null: true
    field :membership, Types::MembershipType, null: true
    field :new_balance_cents, Integer, null: true
    field :errors, [String], null: false

    def resolve(charge_id:, reason: nil)
      org = require_auth!

      result = MemberAccounts::VoidChargeService.call(
        organization: org,
        user: current_user,
        charge_id: charge_id,
        reason: reason
      )

      if result.success?
        {
          charge: result.charge,
          membership: result.membership,
          new_balance_cents: result.new_balance_cents,
          errors: []
        }
      else
        { charge: nil, membership: nil, new_balance_cents: nil, errors: result.errors }
      end
    end
  end
end
