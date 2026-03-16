FactoryBot.define do
  factory :notification_preference do
    user
    email_booking_confirmation { true }
    email_booking_cancellation { true }
    email_booking_reminder { true }
    email_marketing { false }
    sms_booking_confirmation { true }
    sms_booking_cancellation { false }
    sms_booking_reminder { true }
    sms_marketing { false }
    push_booking_confirmation { true }
    push_booking_cancellation { true }
    push_booking_reminder { true }
    push_marketing { false }
    reminder_hours_before { 24 }

    trait :all_disabled do
      email_booking_confirmation { false }
      email_booking_cancellation { false }
      email_booking_reminder { false }
      email_marketing { false }
      sms_booking_confirmation { false }
      sms_booking_cancellation { false }
      sms_booking_reminder { false }
      sms_marketing { false }
      push_booking_confirmation { false }
      push_booking_cancellation { false }
      push_booking_reminder { false }
      push_marketing { false }
    end

    trait :marketing_enabled do
      email_marketing { true }
      sms_marketing { true }
      push_marketing { true }
    end

    trait :early_reminder do
      reminder_hours_before { 1 }
    end

    trait :late_reminder do
      reminder_hours_before { 48 }
    end
  end
end