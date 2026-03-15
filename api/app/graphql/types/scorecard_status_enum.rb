module Types
  class ScorecardStatusEnum < BaseEnum
    description "Status of a scorecard"

    value "IN_PROGRESS", "Scorecard is being actively filled", value: "in_progress"
    value "COMPLETED", "Scorecard has been finalized", value: "completed"
    value "ABANDONED", "Scorecard was abandoned", value: "abandoned"
  end
end
