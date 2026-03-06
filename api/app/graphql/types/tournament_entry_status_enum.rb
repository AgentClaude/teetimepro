module Types
  class TournamentEntryStatusEnum < Types::BaseEnum
    value "REGISTERED", value: "registered"
    value "CONFIRMED", value: "confirmed"
    value "WITHDRAWN", value: "withdrawn"
    value "DISQUALIFIED", value: "disqualified"
  end
end
