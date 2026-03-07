FactoryBot.define do
  factory :pricing_rule do
    association :organization
    name { "Weekend Premium" }
    rule_type { "day_of_week" }
    conditions { { days: ["saturday", "sunday"] } }
    multiplier { 1.25 }
    flat_adjustment_cents { 0 }
    priority { 100 }
    active { true }

    trait :time_of_day do
      name { "Peak Morning" }
      rule_type { "time_of_day" }
      conditions { { hours: { start: 7, end: 11 } } }
      multiplier { 1.15 }
    end

    trait :occupancy do
      name { "High Occupancy" }
      rule_type { "occupancy" }
      conditions { { threshold: 80, operator: "greater_than" } }
      multiplier { 1.10 }
    end

    trait :last_minute do
      name { "Last Minute Discount" }
      rule_type { "last_minute" }
      conditions { { hours: 2 } }
      multiplier { 0.75 }
    end

    trait :advance_booking do
      name { "Early Bird Discount" }
      rule_type { "advance_booking" }
      conditions { { hours: 72, operator: "greater_than" } }
      multiplier { 0.90 }
    end

    trait :flat_adjustment do
      name { "Holiday Surcharge" }
      multiplier { 1.0 }
      flat_adjustment_cents { 500 } # $5
    end

    trait :with_course do
      association :course
    end

    trait :inactive do
      active { false }
    end

    trait :with_date_range do
      start_date { 30.days.ago.to_date }
      end_date { 30.days.from_now.to_date }
    end

    trait :expired do
      start_date { 90.days.ago.to_date }
      end_date { 30.days.ago.to_date }
    end

    trait :future do
      start_date { 30.days.from_now.to_date }
      end_date { 60.days.from_now.to_date }
    end
  end
end