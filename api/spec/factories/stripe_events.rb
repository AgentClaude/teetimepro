FactoryBot.define do
  factory :stripe_event do
    sequence(:stripe_event_id) { |n| "evt_test_#{n}" }
    event_type { "payment_intent.succeeded" }
    payload {
      {
        id: "pi_test_#{SecureRandom.hex(8)}",
        object: "payment_intent",
        amount: 2000,
        currency: "usd",
        status: "succeeded",
        metadata: {
          booking_id: "123",
          confirmation_code: "ABC123"
        }
      }
    }
    status { :pending }

    trait :pending do
      status { :pending }
      processed_at { nil }
      error_message { nil }
    end

    trait :processed do
      status { :processed }
      processed_at { Time.current }
      error_message { nil }
    end

    trait :failed do
      status { :failed }
      processed_at { nil }
      error_message { "Test error message" }
    end

    trait :payment_succeeded do
      event_type { "payment_intent.succeeded" }
      payload {
        {
          id: "pi_test_#{SecureRandom.hex(8)}",
          object: "payment_intent",
          amount: 2000,
          currency: "usd",
          status: "succeeded"
        }
      }
    end

    trait :payment_failed do
      event_type { "payment_intent.payment_failed" }
      payload {
        {
          id: "pi_test_#{SecureRandom.hex(8)}",
          object: "payment_intent",
          amount: 2000,
          currency: "usd",
          status: "failed"
        }
      }
    end

    trait :charge_refunded do
      event_type { "charge.refunded" }
      payload {
        {
          data: {
            object: {
              id: "ch_test_#{SecureRandom.hex(8)}",
              object: "charge",
              amount: 2000,
              amount_refunded: 2000,
              payment_intent: "pi_test_#{SecureRandom.hex(8)}"
            }
          }
        }
      }
    end

    trait :charge_disputed do
      event_type { "charge.dispute.created" }
      payload {
        {
          data: {
            object: {
              id: "dp_test_#{SecureRandom.hex(8)}",
              object: "dispute",
              amount: 2000,
              charge: "ch_test_#{SecureRandom.hex(8)}"
            }
          }
        }
      }
    end
  end
end