module Types
  class VoiceDailyStatsType < Types::BaseObject
    description "Voice call statistics for a single day"

    field :date, GraphQL::Types::ISO8601Date, null: false,
          description: "Date for these statistics"
    
    field :count, Integer, null: false,
          description: "Number of calls on this date"
  end
end