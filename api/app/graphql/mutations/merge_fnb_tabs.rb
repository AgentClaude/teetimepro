module Mutations
  class MergeFnbTabs < BaseMutation
    argument :target_tab_id, ID, required: true
    argument :source_tab_ids, [ID], required: true

    field :target_tab, Types::FnbTabType, null: true
    field :merged_tabs, [Types::FnbTabType], null: true
    field :items_merged, Integer, null: true
    field :errors, [String], null: false

    def resolve(target_tab_id:, source_tab_ids:)
      org = require_auth!

      result = FoodBeverage::MergeTabsService.call(
        organization: org,
        user: current_user,
        target_tab_id: target_tab_id,
        source_tab_ids: source_tab_ids
      )

      if result.success?
        { 
          target_tab: result.target_tab, 
          merged_tabs: result.merged_tabs,
          items_merged: result.items_merged,
          errors: [] 
        }
      else
        { target_tab: nil, merged_tabs: nil, items_merged: nil, errors: result.errors }
      end
    end
  end
end
