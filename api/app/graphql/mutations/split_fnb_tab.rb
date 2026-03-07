module Mutations
  class SplitFnbTab < BaseMutation
    argument :source_tab_id, ID, required: true
    argument :new_golfer_names, [String], required: true
    argument :split_items, [Types::SplitItemInput], required: true

    field :source_tab, Types::FnbTabType, null: true
    field :new_tabs, [Types::FnbTabType], null: true
    field :errors, [String], null: false

    def resolve(source_tab_id:, new_golfer_names:, split_items:)
      org = require_auth!

      result = FoodBeverage::SplitTabService.call(
        organization: org,
        user: current_user,
        source_tab_id: source_tab_id,
        new_golfer_names: new_golfer_names,
        split_items: split_items.map { |item| { golfer_name: item.golfer_name, item_ids: item.item_ids } }
      )

      if result.success?
        {
          source_tab: result.source_tab,
          new_tabs: result.new_tabs,
          errors: []
        }
      else
        { source_tab: nil, new_tabs: nil, errors: result.errors }
      end
    end
  end
end
