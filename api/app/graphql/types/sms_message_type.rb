# frozen_string_literal: true

module Types
  class SmsMessageType < Types::BaseObject
    field :id, ID, null: false
    field :to_phone, String, null: false
    field :status, String, null: false
    field :error_code, String, null: true
    field :error_message, String, null: true
    field :sent_at, GraphQL::Types::ISO8601DateTime, null: true
    field :delivered_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false

    # Mask phone number for privacy
    def to_phone
      phone = object.to_phone
      return phone if phone.length <= 4

      "#{"*" * (phone.length - 4)}#{phone[-4..]}"
    end
  end
end
