module Types
  class AvailabilitySearchResultType < Types::BaseObject
    description "Result of an availability search with slots and metadata"

    field :slots, [Types::AvailableSlotType], null: false
    field :total_available, Integer, null: false
    field :date_range, Types::DateRangeType, null: false
    field :filters, Types::AvailabilityFiltersType, null: false
  end
end
