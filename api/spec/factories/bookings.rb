FactoryBot.define do
  factory :booking do
    tee_time
    user
    players_count { 2 }
    total_cents { 15000 }
    total_currency { "USD" }
    status { :confirmed }
    confirmation_code { SecureRandom.alphanumeric(8).upcase }

    trait :with_players do
      after(:create) do |booking|
        booking.players_count.times do |i|
          create(:booking_player,
            booking: booking,
            name: i.zero? ? booking.user.full_name : Faker::Name.name
          )
        end
      end
    end

    trait :cancelled do
      status { :cancelled }
      cancelled_at { Time.current }
      cancellation_reason { "Changed plans" }
    end

    trait :checked_in do
      status { :checked_in }
    end

    trait :with_payment do
      after(:create) do |booking|
        create(:payment, booking: booking, amount_cents: booking.total_cents)
      end
    end
  end

  factory :booking_player do
    booking
    name { Faker::Name.name }
    golfer_profile { nil }
  end

  factory :payment do
    booking
    amount_cents { 15000 }
    amount_currency { "USD" }
    status { :completed }
    stripe_payment_intent_id { "pi_#{SecureRandom.hex(12)}" }
  end

  end
