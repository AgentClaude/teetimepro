module Types
  class TournamentStatusEnum < Types::BaseEnum
    value "DRAFT", value: "draft"
    value "REGISTRATION_OPEN", value: "registration_open"
    value "REGISTRATION_CLOSED", value: "registration_closed"
    value "IN_PROGRESS", value: "in_progress"
    value "COMPLETED", value: "completed"
    value "CANCELLED", value: "cancelled"
  end
end
