module Types
  class PaymentProviderEnum < Types::BaseEnum
    value "STRIPE", value: "stripe"
    value "MANUAL", value: "manual"
  end
end
