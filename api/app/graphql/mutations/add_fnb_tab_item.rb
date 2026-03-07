module Mutations
  class AddFnbTabItem < BaseMutation
    argument :tab_id, ID, required: true
    argument :name, String, required: true
    argument :quantity, Integer, required: true
    argument :unit_price_cents, Integer, required: true
    argument :category, Types::FnbTabItemCategoryEnum, required: false
    argument :notes, String, required: false

    field :fnb_tab_item, Types::FnbTabItemType, null: true
    field :fnb_tab, Types::FnbTabType, null: true
    field :errors, [String], null: false

    def resolve(tab_id:, name:, quantity:, unit_price_cents:, category: nil, notes: nil)
      org = require_auth!

      result = FoodBeverage::AddTabItemService.call(
        organization: org,
        user: current_user,
        tab_id: tab_id,
        name: name,
        quantity: quantity,
        unit_price_cents: unit_price_cents,
        category: category&.downcase || 'food',
        notes: notes
      )

      if result.success?
        { fnb_tab_item: result.item, fnb_tab: result.tab, errors: [] }
      else
        { fnb_tab_item: nil, fnb_tab: nil, errors: result.errors }
      end
    end
  end
end