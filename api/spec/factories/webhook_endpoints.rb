FactoryBot.define do
  factory :webhook_endpoint do
    association :organization
    url { "https://example.com/webhooks/#{SecureRandom.hex(8)}" }
    events { ["booking.created", "booking.cancelled"] }
    active { true }
    description { "Test webhook endpoint" }

    trait :inactive do
      active { false }
    end

    trait :with_all_events do
      events { WebhookEndpoint::AVAILABLE_EVENTS }
    end

    trait :booking_events_only do
      events { ["booking.created", "booking.cancelled", "booking.checked_in"] }
    end

    trait :payment_events_only do
      events { ["payment.completed", "payment.refunded"] }
    end
  end
end