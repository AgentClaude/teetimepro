# frozen_string_literal: true

module Types
  class EmailMessageType < Types::BaseObject
    field :id, ID, null: false
    field :to_email, String, null: false
    field :status, String, null: false
    field :error_message, String, null: true
    field :opened_at, GraphQL::Types::ISO8601DateTime, null: true
    field :clicked_at, GraphQL::Types::ISO8601DateTime, null: true
    field :sent_at, GraphQL::Types::ISO8601DateTime, null: true
    field :delivered_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false

    # Mask email for privacy - show first 3 chars and domain
    def to_email
      email = object.to_email
      return email if email.length <= 6 || !email.include?('@')

      local, domain = email.split('@', 2)
      masked_local = if local.length <= 3
                       local
                     else
                       "#{local[0..2]}#{"*" * (local.length - 3)}"
                     end

      "#{masked_local}@#{domain}"
    end
  end
end