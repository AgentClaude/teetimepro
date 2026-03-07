FactoryBot.define do
  factory :marketplace_connection do
    organization
    course
    provider { "golfnow" }
    status { :active }
    external_course_id { "gn_#{SecureRandom.hex(4)}" }
    credentials { { "api_key" => "test_key_#{SecureRandom.hex(8)}" } }
    settings { {} }

    trait :golfnow do
      provider { "golfnow" }
      external_course_id { "gn_#{SecureRandom.hex(4)}" }
    end

    trait :teeoff do
      provider { "teeoff" }
      external_course_id { "to_#{SecureRandom.hex(4)}" }
    end

    trait :pending do
      status { :pending }
    end

    trait :paused do
      status { :paused }
    end

    trait :error do
      status { :error }
      last_error { "API connection failed" }
    end

    trait :with_settings do
      settings do
        {
          "auto_syndicate" => true,
          "min_advance_hours" => 4,
          "max_advance_days" => 14,
          "discount_percent" => 10,
          "min_available_spots" => 2
        }
      end
    end
  end

  factory :marketplace_listing do
    marketplace_connection
    tee_time
    status { :listed }
    external_listing_id { "listing_#{SecureRandom.hex(8)}" }
    listed_price_cents { 6750 }
    listed_price_currency { "USD" }
    commission_rate_bps { 1500 }
    listed_at { Time.current }
    expires_at { 1.day.from_now }

    trait :pending do
      status { :pending }
      external_listing_id { nil }
      listed_at { nil }
    end

    trait :booked do
      status { :booked }
    end

    trait :expired do
      status { :expired }
    end

    trait :error do
      status { :error }
    end
  end
end
