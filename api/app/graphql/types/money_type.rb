module Types
  class MoneyType < Types::BaseObject
    field :cents, Integer, null: false
    field :currency, String, null: false
    field :amount, Float, null: false

    def amount
      object.to_f
    end

    def cents
      object.cents
    end

    def currency
      object.currency.to_s
    end
  end
end
