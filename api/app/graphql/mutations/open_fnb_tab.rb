module Mutations
  class OpenFnbTab < BaseMutation
    argument :course_id, ID, required: true
    argument :golfer_name, String, required: true

    field :fnb_tab, Types::FnbTabType, null: true
    field :errors, [String], null: false

    def resolve(course_id:, golfer_name:)
      org = require_auth!

      result = FoodBeverage::OpenTabService.call(
        organization: org,
        user: current_user,
        course_id: course_id,
        golfer_name: golfer_name
      )

      if result.success?
        { fnb_tab: result.tab, errors: [] }
      else
        { fnb_tab: nil, errors: result.errors }
      end
    end
  end
end
