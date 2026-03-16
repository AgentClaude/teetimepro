# frozen_string_literal: true

FactoryBot.define do
  factory :device_token do
    association :user
    organization { user.organization }
    token { "ExponentPushToken[#{SecureRandom.alphanumeric(22)}]" }
    platform { %w[ios android].sample }
    device_id { SecureRandom.uuid }
    active { true }
    last_used_at { Time.current }
  end
end
