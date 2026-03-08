# frozen_string_literal: true

FactoryBot.define do
  factory :prepaid_purchase do
    prepaid_package
    organization { prepaid_package.organization }
    user { association :user, organization: organization }
    status { :active }
    purchased_at { Time.current }
    activated_at { Time.current }

    after(:build) do |purchase|
      if purchase.prepaid_package.round_pack?
        purchase.rounds_remaining = purchase.prepaid_package.rounds_included
      elsif purchase.prepaid_package.value_card?
        purchase.balance_cents = purchase.prepaid_package.value_cents
      end
    end

    trait :expired do
      status { :expired }
      expires_at { 1.day.ago }
    end

    trait :fully_redeemed do
      status { :fully_redeemed }
      rounds_remaining { 0 }
    end

    trait :with_expiry do
      expires_at { 90.days.from_now }
    end

    trait :value_card do
      prepaid_package { association :prepaid_package, :value_card }
    end

    trait :time_pass do
      prepaid_package { association :prepaid_package, :time_pass }
    end
  end
end
