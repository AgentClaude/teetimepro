module Types
  class PaymentType < Types::BaseObject
    field :id, ID, null: false
    field :booking, Types::BookingType, null: false
    field :status, Types::PaymentStatusEnum, null: false
    field :amount, Types::MoneyType, null: false
    field :refund_amount, Types::MoneyType, null: true
    field :stripe_payment_intent_id, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Helper fields
    field :fully_refundable, Boolean, null: false
    field :remaining_refundable_amount, Types::MoneyType, null: false

    def fully_refundable
      object.fully_refundable?
    end

    def remaining_refundable_amount
      Money.new(object.remaining_refundable_amount)
    end
  end
end
