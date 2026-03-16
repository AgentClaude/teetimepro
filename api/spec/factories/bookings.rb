FactoryBot.define do
  factory :booking do
    transient do
      organization { nil }
    end

    tee_time { association :tee_time, tee_sheet: association(:tee_sheet, course: association(:course, organization: organization || association(:organization))) }
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
        create(:payment, :captured, booking: booking, amount_cents: booking.total_cents)
      end
    end
  end

  factory :booking_player do
    booking
    name { Faker::Name.name }
    golfer_profile { nil }
  end
end
