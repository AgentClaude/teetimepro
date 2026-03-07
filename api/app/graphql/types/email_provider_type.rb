# frozen_string_literal: true

module Types
  class EmailProviderType < Types::BaseObject
    field :id, ID, null: false
    field :provider_type, String, null: false
    field :from_email, String, null: false
    field :from_name, String, null: true
    field :is_active, Boolean, null: false
    field :is_default, Boolean, null: false
    field :verification_status, String, null: false
    field :last_verified_at, GraphQL::Types::ISO8601DateTime, null: true
    field :masked_api_key, String, null: false
    field :settings, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def masked_api_key
      object.masked_api_key
    end
  end
end
