FactoryBot.define do
  factory :email_message do
    email_campaign
    user
    to_email { Faker::Internet.email }
    status { :pending }

    trait :sent do
      status { :sent }
      sent_at { Time.current }
    end

    trait :delivered do
      status { :delivered }
      sent_at { 5.minutes.ago }
      delivered_at { 1.minute.ago }
    end

    trait :opened do
      status { :opened }
      sent_at { 10.minutes.ago }
      delivered_at { 8.minutes.ago }
      opened_at { 2.minutes.ago }
    end

    trait :clicked do
      status { :clicked }
      sent_at { 10.minutes.ago }
      delivered_at { 8.minutes.ago }
      opened_at { 5.minutes.ago }
      clicked_at { 1.minute.ago }
    end

    trait :bounced do
      status { :bounced }
      error_message { "Mailbox not found" }
    end

    trait :failed do
      status { :failed }
      error_message { "SMTP connection timeout" }
    end
  end
end
