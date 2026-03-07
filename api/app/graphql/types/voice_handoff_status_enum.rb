module Types
  class VoiceHandoffStatusEnum < Types::BaseEnum
    value "PENDING", value: "pending", description: "Waiting for staff to connect"
    value "CONNECTED", value: "connected", description: "Staff member has answered"
    value "COMPLETED", value: "completed", description: "Call completed successfully"
    value "MISSED", value: "missed", description: "No staff member answered"
    value "CANCELLED", value: "cancelled", description: "Handoff was cancelled"
  end
end