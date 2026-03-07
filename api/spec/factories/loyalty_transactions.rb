FactoryBot.define do
  factory :loyalty_transaction do
    association :loyalty_account
    transaction_type { :earn }
    points { 100 }
    description { "Points earned from booking" }
    balance_after { loyalty_account.points_balance + points }

    trait :earning do
      transaction_type { :earn }
      points { 50 }
      description { "Earned points for activity" }
    end

    trait :redemption do
      transaction_type { :redeem }
      points { -200 }
      description { "Redeemed points for reward" }
    end

    trait :adjustment do
      transaction_type { :adjust }
      points { 25 }
      description { "Manual adjustment by admin" }
    end

    trait :expiration do
      transaction_type { :expire }
      points { -50 }
      description { "Points expired" }
    end

    trait :with_source do
      association :source, factory: :booking
    end

    # Ensure balance_after reflects the correct state
    after(:build) do |transaction|
      transaction.balance_after = transaction.loyalty_account.points_balance + transaction.points
    end
  end
end