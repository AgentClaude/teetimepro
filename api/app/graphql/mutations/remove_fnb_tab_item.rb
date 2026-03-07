module Mutations
  class RemoveFnbTabItem < BaseMutation
    argument :tab_item_id, ID, required: true

    field :fnb_tab, Types::FnbTabType, null: true
    field :removed_item_id, ID, null: true
    field :errors, [String], null: false

    def resolve(tab_item_id:)
      org = require_auth!

      result = FoodBeverage::RemoveTabItemService.call(
        organization: org,
        user: current_user,
        tab_item_id: tab_item_id
      )

      if result.success?
        { fnb_tab: result.tab, removed_item_id: tab_item_id, errors: [] }
      else
        { fnb_tab: nil, removed_item_id: nil, errors: result.errors }
      end
    end
  end
end
