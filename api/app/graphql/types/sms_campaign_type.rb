# frozen_string_literal: true

module Types
  class SmsCampaignType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :message_body, String, null: false
    field :status, String, null: false
    field :recipient_filter, String, null: false
    field :filter_criteria, GraphQL::Types::JSON, null: false
    field :total_recipients, Integer, null: false
    field :sent_count, Integer, null: false
    field :delivered_count, Integer, null: false
    field :failed_count, Integer, null: false
    field :progress_percentage, Float, null: false
    field :scheduled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :sent_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_by, Types::UserType, null: false
    field :sms_messages, [Types::SmsMessageType], null: false

    def sms_messages
      object.sms_messages.order(created_at: :desc).limit(100)
    end
  end
end
