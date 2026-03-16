module Types
  class NotificationPreferenceType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :email_booking_confirmation, Boolean, null: false
    field :email_booking_cancellation, Boolean, null: false
    field :email_booking_reminder, Boolean, null: false
    field :email_marketing, Boolean, null: false
    field :sms_booking_confirmation, Boolean, null: false
    field :sms_booking_cancellation, Boolean, null: false
    field :sms_booking_reminder, Boolean, null: false
    field :sms_marketing, Boolean, null: false
    field :push_booking_confirmation, Boolean, null: false
    field :push_booking_cancellation, Boolean, null: false
    field :push_booking_reminder, Boolean, null: false
    field :push_marketing, Boolean, null: false
    field :reminder_hours_before, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: false
  end
end