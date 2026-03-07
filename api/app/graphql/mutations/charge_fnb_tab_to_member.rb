module Mutations
  class ChargeFnbTabToMember < BaseMutation
    argument :tab_id, ID, required: true
    argument :membership_id, ID, required: true
    argument :notes, String, required: false

    field :charge, Types::MemberAccountChargeType, null: true
    field :fnb_tab, Types::FnbTabType, null: true
    field :membership, Types::MembershipType, null: true
    field :new_balance_cents, Integer, null: true
    field :errors, [String], null: false

    def resolve(tab_id:, membership_id:, notes: nil)
      org = require_auth!

      result = MemberAccounts::ChargeFnbTabService.call(
        organization: org,
        user: current_user,
        tab_id: tab_id,
        membership_id: membership_id,
        notes: notes
      )

      if result.success?
        {
          charge: result.charge,
          fnb_tab: result.fnb_tab,
          membership: result.membership,
          new_balance_cents: result.new_balance_cents,
          errors: []
        }
      else
        { charge: nil, fnb_tab: nil, membership: nil, new_balance_cents: nil, errors: result.errors }
      end
    end
  end
end
