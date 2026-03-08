# frozen_string_literal: true

FactoryBot.define do
  factory :prepaid_redemption do
    prepaid_purchase
    booking
    user { prepaid_purchase.user }
    redemption_type { :round }
    rounds_used { 1 }

    trait :value do
      redemption_type { :value }
      rounds_used { nil }
      value_cents { 5000 }
    end
  end
end
