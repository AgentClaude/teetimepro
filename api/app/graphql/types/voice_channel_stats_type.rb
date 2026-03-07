module Types
  class VoiceChannelStatsType < Types::BaseObject
    description "Voice call statistics by channel"

    field :channel, String, null: false,
          description: "Channel name (browser or twilio)"
    
    field :count, Integer, null: false,
          description: "Number of calls for this channel"
  end
end