FactoryBot.define do
  factory :course do
    organization
    name { "#{Faker::Address.community} Golf Course" }
    holes { 18 }
    interval_minutes { 10 }
    max_players_per_slot { 4 }
    first_tee_time { Time.zone.parse("06:00") }
    last_tee_time { Time.zone.parse("17:00") }
    weekday_rate_cents { 7500 }
    weekday_rate_currency { "USD" }
    weekend_rate_cents { 9500 }
    weekend_rate_currency { "USD" }
    twilight_rate_cents { 4500 }
    twilight_rate_currency { "USD" }

    trait :nine_holes do
      holes { 9 }
      weekday_rate_cents { 4000 }
      weekend_rate_cents { 5000 }
    end

    trait :eight_minute_intervals do
      interval_minutes { 8 }
    end
  end
end
