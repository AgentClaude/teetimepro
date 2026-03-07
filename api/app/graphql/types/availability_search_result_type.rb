module Types
  class AvailabilitySearchResultType < Types::BaseObject
    description "Result of an availability search with slots and metadata"

    field :slots, [Types::AvailableSlotType], null: false
    field :total_available, Integer, null: false
    field :date_range, Types::DateRangeType, null: false
    field :filters, Types::AvailabilityFiltersType, null: false
  end

  class DateRangeType < Types::BaseObject
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: false
    field :days, Integer, null: false
  end

  class AvailabilityFiltersType < Types::BaseObject
    field :players, Integer, null: false
    field :time_preference, String, null: true
    field :course_id, ID, null: true
  end
end
