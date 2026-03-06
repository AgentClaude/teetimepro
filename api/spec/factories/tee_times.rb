FactoryBot.define do
  factory :tee_sheet do
    course
    date { Date.tomorrow }

    trait :today do
      date { Date.current }
    end
  end

  factory :tee_time do
    tee_sheet
    starts_at { Date.tomorrow.beginning_of_day + 8.hours }
    max_players { 4 }
    booked_players { 0 }
    status { :available }
    price_cents { 7500 }
    price_currency { "USD" }

    trait :partially_booked do
      booked_players { 2 }
      status { :partially_booked }
    end

    trait :fully_booked do
      booked_players { 4 }
      status { :fully_booked }
    end

    trait :blocked do
      status { :blocked }
      notes { "Course maintenance" }
    end

    trait :afternoon do
      starts_at { Date.tomorrow.beginning_of_day + 14.hours }
    end

    trait :past do
      starts_at { 2.hours.ago }
    end
  end
end
