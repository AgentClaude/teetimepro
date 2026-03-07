module Types
  class VoiceHandoffReasonEnum < Types::BaseEnum
    value "BILLING_INQUIRY", value: "billing_inquiry", description: "Billing questions or disputes"
    value "COMPLAINT", value: "complaint", description: "Service complaints or issues"
    value "GROUP_EVENT", value: "group_event", description: "Group event inquiry (10+ players)"
    value "TOURNAMENT", value: "tournament", description: "Tournament-related questions"
    value "MANAGER_REQUEST", value: "manager_request", description: "Caller requested to speak to manager"
    value "OTHER", value: "other", description: "Other reason requiring human assistance"
  end
end