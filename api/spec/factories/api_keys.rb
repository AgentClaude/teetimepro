FactoryBot.define do
  factory :api_key do
    association :organization
    sequence(:name) { |n| "API Key #{n}" }
    active { true }
    scopes { ['read'] }
    rate_limit_tier { 'standard' }
    expires_at { 1.year.from_now }

    trait :premium do
      rate_limit_tier { 'premium' }
    end

    trait :enterprise do
      rate_limit_tier { 'enterprise' }
    end

    trait :with_write_access do
      scopes { ['read', 'write'] }
    end

    trait :with_admin_access do
      scopes { ['read', 'write', 'admin'] }
    end

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :inactive do
      active { false }
    end
  end
end
