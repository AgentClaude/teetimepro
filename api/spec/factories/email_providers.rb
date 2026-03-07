# frozen_string_literal: true

FactoryBot.define do
  factory :email_provider do
    association :organization
    provider_type { "sendgrid" }
    api_key { "SG.#{SecureRandom.hex(16)}" }
    from_email { "noreply@#{organization.name.parameterize}.com" }
    from_name { organization.name }
    is_active { true }
    is_default { true }
    verification_status { "verified" }
    settings { {} }

    trait :sendgrid do
      provider_type { "sendgrid" }
      api_key { "SG.#{SecureRandom.hex(16)}" }
    end

    trait :mailchimp do
      provider_type { "mailchimp" }
      api_key { "mc-#{SecureRandom.hex(16)}" }
    end

    trait :unverified do
      verification_status { "pending" }
    end

    trait :failed_verification do
      verification_status { "failed" }
    end

    trait :inactive do
      is_active { false }
    end

    trait :with_webhook_secret do
      webhook_secret { SecureRandom.hex(32) }
    end
  end
end
