module Types
  class UtilizationHeatMapSummaryType < Types::BaseObject
    description "Summary statistics for the utilization heat map"

    field :overall_utilization, Float, null: false
    field :total_booked_players, Integer, null: false
    field :total_capacity, Integer, null: false
    field :peak_hour, Integer, null: true, description: "Hour with highest utilization (0-23)"
    field :peak_hour_utilization, Float, null: false
    field :peak_day_of_week, String, null: true, description: "Day name with highest utilization"
    field :peak_day_utilization, Float, null: false
    field :date_range_days, Integer, null: false
  end
end
