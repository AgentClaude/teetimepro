module Types
  class AccountingSyncStatusEnum < Types::BaseEnum
    value "PENDING", value: "pending"
    value "IN_PROGRESS", value: "in_progress"
    value "COMPLETED", value: "completed"
    value "FAILED", value: "failed"
  end
end
