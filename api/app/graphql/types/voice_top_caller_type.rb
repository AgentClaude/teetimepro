module Types
  class VoiceTopCallerType < Types::BaseObject
    description "Statistics for a frequent voice bot caller"

    field :phone, String, null: false,
          description: "Caller's phone number"
    
    field :name, String, null: false,
          description: "Caller's name (or 'Unknown' if not available)"
    
    field :total_calls, Integer, null: false,
          description: "Total number of calls from this caller"
    
    field :average_duration_seconds, Integer, null: false,
          description: "Average call duration for this caller"
  end
end