FactoryBot.define do
  factory :webhook_event do
    association :webhook_endpoint
    event_type { "booking.created" }
    payload { 
      {
        id: 123,
        type: "booking",
        attributes: {
          confirmation_code: "ABC123",
          players_count: 2,
          total_cents: 8000
        },
        timestamp: Time.current.iso8601
      }
    }
    status { :pending }
    attempts { 0 }

    trait :delivered do
      status { :delivered }
      delivered_at { Time.current }
      response_code { 200 }
      attempts { 1 }
    end

    trait :failed do
      status { :failed }
      attempts { 5 }
      response_code { 500 }
      response_body { "Internal Server Error" }
      last_attempted_at { Time.current }
    end

    trait :with_retries do
      attempts { 2 }
      last_attempted_at { 1.hour.ago }
    end

    trait :booking_created do
      event_type { "booking.created" }
    end

    trait :booking_cancelled do
      event_type { "booking.cancelled" }
    end

    trait :payment_completed do
      event_type { "payment.completed" }
      payload {
        {
          id: 456,
          type: "payment",
          attributes: {
            amount_cents: 8000,
            currency: "USD",
            status: "completed"
          },
          timestamp: Time.current.iso8601
        }
      }
    end
  end
end