FactoryBot.define do
  factory :loyalty_redemption do
    association :loyalty_account
    association :loyalty_reward
    status { :pending }
    code { "RED-#{SecureRandom.hex(4).upcase}" }
    expires_at { 30.days.from_now }

    trait :applied do
      status { :applied }
      association :booking
    end

    trait :expired do
      status { :expired }
      expires_at { 1.day.ago }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :with_booking do
      association :booking
    end

    trait :expires_soon do
      expires_at { 2.days.from_now }
    end

    trait :expires_today do
      expires_at { 1.hour.from_now }
    end

    # Ensure unique codes
    sequence :code do |n|
      "RED-#{n.to_s.rjust(4, '0')}"
    end
  end
end