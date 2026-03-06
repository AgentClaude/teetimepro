module Types
  class TeeSheetType < Types::BaseObject
    field :id, ID, null: false
    field :date, GraphQL::Types::ISO8601Date, null: false
    field :course_id, ID, null: false
    field :total_slots, Integer, null: false
    field :available_slots, Integer, null: false
    field :utilization_percentage, Float, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :tee_times, [Types::TeeTimeType], null: false
    field :course, Types::CourseType, null: false

    def tee_times
      object.tee_times.order(:starts_at)
    end
  end
end
