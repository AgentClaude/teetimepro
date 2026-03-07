# frozen_string_literal: true

module Types
  class EmailCampaignType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :subject, String, null: false
    field :body_html, String, null: false
    field :body_text, String, null: true
    field :status, String, null: false
    field :recipient_filter, String, null: false
    field :filter_criteria, GraphQL::Types::JSON, null: false
    field :lapsed_days, Integer, null: false
    field :is_automated, Boolean, null: false
    field :recurrence_interval_days, Integer, null: true
    field :total_recipients, Integer, null: false
    field :sent_count, Integer, null: false
    field :delivered_count, Integer, null: false
    field :opened_count, Integer, null: false
    field :clicked_count, Integer, null: false
    field :failed_count, Integer, null: false
    field :progress_percentage, Float, null: false
    field :open_rate_percentage, Float, null: false
    field :click_rate_percentage, Float, null: false
    field :scheduled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :sent_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_by, Types::UserType, null: false
    field :email_messages, [Types::EmailMessageType], null: false

    def email_messages
      object.email_messages.order(created_at: :desc).limit(100)
    end
  end
end
