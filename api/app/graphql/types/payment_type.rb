module Types
  class PaymentType < Types::BaseObject
    field :id, ID, null: false
    field :booking, Types::BookingType, null: false
    field :organization, Types::OrganizationType, null: true
    field :user, Types::UserType, null: true
    field :status, Types::PaymentStatusEnum, null: false
    field :payment_method, Types::PaymentMethodEnum, null: false
    field :provider, Types::PaymentProviderEnum, null: false
    field :amount, Types::MoneyType, null: false
    field :refund_amount, Types::MoneyType, null: true
    field :provider_transaction_id, String, null: true
    field :stripe_payment_intent_id, String, null: true
    field :refund_reason, String, null: true
    field :metadata, GraphQL::Types::JSON, null: true
    field :paid_at, GraphQL::Types::ISO8601DateTime, null: true
    field :refunded_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Helper fields
    field :fully_refundable, Boolean, null: false
    field :remaining_refundable_amount, Types::MoneyType, null: false
    field :capturable, Boolean, null: false
    field :refundable, Boolean, null: false

    def fully_refundable
      object.fully_refundable?
    end

    def remaining_refundable_amount
      Money.new(object.remaining_refundable_amount)
    end

    def capturable
      object.capturable?
    end

    def refundable
      object.refundable?
    end
  end
end
