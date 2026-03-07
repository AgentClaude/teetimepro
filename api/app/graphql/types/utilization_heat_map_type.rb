module Types
  class UtilizationHeatMapType < Types::BaseObject
    description "Utilization heat map data for occupancy visualization"

    field :cells, [Types::UtilizationHeatMapCellType], null: false
    field :summary, Types::UtilizationHeatMapSummaryType, null: false
  end
end
