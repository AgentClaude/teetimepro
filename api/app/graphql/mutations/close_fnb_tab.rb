module Mutations
  class CloseFnbTab < BaseMutation
    argument :tab_id, ID, required: true
    argument :payment_method, String, required: false

    field :fnb_tab, Types::FnbTabType, null: true
    field :final_total_cents, Integer, null: true
    field :errors, [String], null: false

    def resolve(tab_id:, payment_method: nil)
      org = require_auth!

      result = FoodBeverage::CloseTabService.call(
        organization: org,
        user: current_user,
        tab_id: tab_id,
        payment_method: payment_method
      )

      if result.success?
        { fnb_tab: result.tab, final_total_cents: result.final_total_cents, errors: [] }
      else
        { fnb_tab: nil, final_total_cents: nil, errors: result.errors }
      end
    end
  end
end