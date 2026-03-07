module Types
  class PaymentStatusEnum < Types::BaseEnum
    value "PENDING", value: "pending"
    value "AUTHORIZED", value: "authorized"
    value "CAPTURED", value: "captured"
    value "COMPLETED", value: "completed"
    value "FAILED", value: "failed"
    value "REFUNDED", value: "refunded"
    value "PARTIALLY_REFUNDED", value: "partially_refunded"
    value "CANCELLED", value: "cancelled"
  end
end
