module Types
  class AccountingSyncTypeEnum < Types::BaseEnum
    value "INVOICE", value: "invoice"
    value "PAYMENT", value: "payment"
    value "REFUND", value: "refund"
  end
end
