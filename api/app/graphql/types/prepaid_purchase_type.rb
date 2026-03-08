# frozen_string_literal: true

module Types
  class PrepaidPurchaseType < Types::BaseObject
    field :id, ID, null: false
    field :prepaid_package, Types::PrepaidPackageType, null: false
    field :user, Types::UserType, null: false
    field :payment, Types::PaymentType, null: true
    field :code, String, null: false
    field :status, String, null: false
    field :rounds_remaining, Integer, null: true
    field :balance, Types::MoneyType, null: true
    field :purchased_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime, null: true
    field :activated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :usable, Boolean, null: false
    field :total_rounds_used, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def balance
      return nil unless object.balance_cents.present?

      object.balance
    end

    def usable
      object.usable?
    end

    def total_rounds_used
      object.total_rounds_used
    end
  end
end
