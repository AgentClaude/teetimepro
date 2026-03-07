module Types
  class SplitItemInput < BaseInputObject
    description 'Input for specifying which items to move to which golfer during a tab split'

    argument :golfer_name, String, required: true, description: 'Name of the golfer to assign items to'
    argument :item_ids, [ID], required: true, description: 'IDs of items to move to this golfer'
  end
end
