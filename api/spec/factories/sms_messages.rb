FactoryBot.define do
  factory :sms_message do
    sms_campaign
    user
    to_phone { "+1#{Faker::PhoneNumber.subscriber_number(length: 10)}" }
    status { :pending }

    trait :queued do
      status { :queued }
      twilio_sid { "SM#{SecureRandom.hex(16)}" }
      sent_at { Time.current }
    end

    trait :delivered do
      status { :delivered }
      twilio_sid { "SM#{SecureRandom.hex(16)}" }
      sent_at { 5.minutes.ago }
      delivered_at { 1.minute.ago }
    end

    trait :failed do
      status { :failed }
      error_code { "30006" }
      error_message { "Landline or unreachable carrier" }
    end
  end
end
