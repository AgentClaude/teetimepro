module Types
  class PaymentMethodEnum < Types::BaseEnum
    value "CARD", value: "card"
    value "CASH", value: "cash"
    value "ACCOUNT", value: "account"
  end
end
