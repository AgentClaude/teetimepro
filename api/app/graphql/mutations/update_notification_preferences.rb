module Mutations
  class UpdateNotificationPreferences < BaseMutation
    argument :email_booking_confirmation, Boolean, required: false
    argument :email_booking_cancellation, Boolean, required: false
    argument :email_booking_reminder, Boolean, required: false
    argument :email_marketing, Boolean, required: false
    argument :sms_booking_confirmation, Boolean, required: false
    argument :sms_booking_cancellation, Boolean, required: false
    argument :sms_booking_reminder, Boolean, required: false
    argument :sms_marketing, Boolean, required: false
    argument :push_booking_confirmation, Boolean, required: false
    argument :push_booking_cancellation, Boolean, required: false
    argument :push_booking_reminder, Boolean, required: false
    argument :push_marketing, Boolean, required: false
    argument :reminder_hours_before, Integer, required: false

    field :notification_preference, Types::NotificationPreferenceType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      require_auth!

      result = NotificationPreferences::UpdateService.call(
        user: current_user,
        preferences: args.compact
      )

      if result.success?
        {
          notification_preference: result.notification_preference,
          errors: []
        }
      else
        {
          notification_preference: nil,
          errors: result.errors
        }
      end
    end
  end
end