module Mutations
  class ChargeMemberAccount < BaseMutation
    argument :membership_id, ID, required: true
    argument :amount_cents, Integer, required: true
    argument :charge_type, String, required: true
    argument :description, String, required: true
    argument :notes, String, required: false
    argument :fnb_tab_id, ID, required: false
    argument :booking_id, ID, required: false

    field :charge, Types::MemberAccountChargeType, null: true
    field :membership, Types::MembershipType, null: true
    field :new_balance_cents, Integer, null: true
    field :errors, [String], null: false

    def resolve(membership_id:, amount_cents:, charge_type:, description:, notes: nil, fnb_tab_id: nil, booking_id: nil)
      org = require_auth!

      result = MemberAccounts::ChargeAccountService.call(
        organization: org,
        user: current_user,
        membership_id: membership_id,
        amount_cents: amount_cents,
        charge_type: charge_type,
        description: description,
        notes: notes,
        fnb_tab_id: fnb_tab_id,
        booking_id: booking_id
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
