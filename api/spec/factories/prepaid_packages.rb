# frozen_string_literal: true

FactoryBot.define do
  factory :prepaid_package do
    organization
    name { "10-Round Pack" }
    package_type { :round_pack }
    price_cents { 50000 } # $500
    rounds_included { 10 }
    active { true }
    max_players_per_round { 4 }
    transferable { false }
    restrictions { {} }

    trait :value_card do
      name { "Gift Card" }
      package_type { :value_card }
      rounds_included { nil }
      value_cents { 25000 } # $250
    end

    trait :time_pass do
      name { "Monthly Pass" }
      package_type { :time_pass }
      rounds_included { nil }
      validity_days { 30 }
    end

    trait :with_restrictions do
      restrictions do
        {
          "day_of_week" => ["saturday", "sunday"],
          "time_ranges" => [{ "start" => "06:00", "end" => "14:00" }]
        }
      end
    end

    trait :expired_availability do
      available_until { 1.day.ago }
    end

    trait :inactive do
      active { false }
    end

    trait :with_course do
      course
    end
  end
end
