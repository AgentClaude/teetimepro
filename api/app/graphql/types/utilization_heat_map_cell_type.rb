module Types
  class UtilizationHeatMapCellType < Types::BaseObject
    description "A single cell in the utilization heat map (one hour on one date)"

    field :date, GraphQL::Types::ISO8601Date, null: false
    field :hour, Integer, null: false, description: "Hour of the day (0-23)"
    field :utilization_percentage, Float, null: false
    field :booked_players, Integer, null: false
    field :total_capacity, Integer, null: false
    field :slot_count, Integer, null: false, description: "Number of tee time slots in this hour"
  end
end
