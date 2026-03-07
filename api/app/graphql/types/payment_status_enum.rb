module Types
  class PaymentStatusEnum < Types::BaseEnum
    value "PENDING", value: "pending"
    value "COMPLETED", value: "completed"
    value "FAILED", value: "failed"
    value "REFUNDED", value: "refunded"
    value "PARTIALLY_REFUNDED", value: "partially_refunded"
  end
end
