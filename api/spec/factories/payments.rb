FactoryBot.define do
  factory :payment do
    booking
    organization { booking&.tee_time&.tee_sheet&.course&.organization || association(:organization) }
    user { booking&.user || association(:user) }
    amount_cents { 15000 }
    amount_currency { "USD" }
    status { :pending }
    payment_method { :card }
    provider { :stripe }
    stripe_payment_intent_id { "pi_#{SecureRandom.hex(12)}" }
    metadata { {} }

    trait :authorized do
      status { :authorized }
    end

    trait :captured do
      status { :captured }
      paid_at { Time.current }
    end

    trait :completed do
      status { :completed }
      paid_at { Time.current }
    end

    trait :failed do
      status { :failed }
    end

    trait :refunded do
      status { :refunded }
      refund_amount_cents { 15000 }
      refund_amount_currency { "USD" }
      refund_reason { "Customer requested" }
      refunded_at { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :manual do
      provider { :manual }
      payment_method { :cash }
      stripe_payment_intent_id { nil }
    end

    trait :with_provider_transaction do
      provider_transaction_id { "txn_#{SecureRandom.hex(12)}" }
    end
  end
end
