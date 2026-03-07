module Types
  class VoiceAnalyticsType < Types::BaseObject
    description "Voice bot analytics for the organization"

    field :total_calls, Integer, null: false,
          description: "Total number of voice calls in the date range"
    
    field :completed_calls, Integer, null: false,
          description: "Number of successfully completed calls"
    
    field :error_rate, Float, null: false,
          description: "Percentage of calls that ended in error"
    
    field :average_duration_seconds, Integer, null: false,
          description: "Average call duration in seconds for completed calls"
    
    field :booking_conversion_rate, Float, null: false,
          description: "Percentage of calls that resulted in bookings"
    
    field :calls_by_channel, [Types::VoiceChannelStatsType], null: false,
          description: "Call counts broken down by channel (browser/twilio)"
    
    field :calls_by_day, [Types::VoiceDailyStatsType], null: false,
          description: "Daily call counts over the date range"
    
    field :top_callers, [Types::VoiceTopCallerType], null: false,
          description: "Top 10 callers by number of calls"
  end
end