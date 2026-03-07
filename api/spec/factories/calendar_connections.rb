FactoryBot.define do
  factory :calendar_connection do
    association :user
    provider { "google" }
    access_token { "sample_access_token_#{SecureRandom.alphanumeric(32)}" }
    refresh_token { "sample_refresh_token_#{SecureRandom.alphanumeric(32)}" }
    token_expires_at { 1.hour.from_now }
    enabled { true }
    calendar_id { "primary" }
    calendar_name { "Personal Calendar" }

    trait :google do
      provider { "google" }
      calendar_name { "Google Calendar" }
    end

    trait :apple do
      provider { "apple" }
      calendar_name { "iCloud Calendar" }
      access_token { nil }
      refresh_token { nil }
      token_expires_at { nil }
    end

    trait :disabled do
      enabled { false }
    end

    trait :expired do
      token_expires_at { 1.hour.ago }
    end

    trait :without_refresh_token do
      refresh_token { nil }
    end
  end
end