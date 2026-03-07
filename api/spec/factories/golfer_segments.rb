FactoryBot.define do
  factory :golfer_segment do
    organization
    association :created_by, factory: [:user, :manager]
    name { Faker::Marketing.buzzwords.capitalize }
    description { "A test segment" }
    filter_criteria { { "booking_count_min" => 1 } }
    is_dynamic { true }
    cached_count { 0 }

    trait :static do
      is_dynamic { false }
    end

    trait :high_value do
      name { "High Value" }
      filter_criteria { { "total_spent_min" => 50000, "membership_status" => "active" } }
    end

    trait :lapsed do
      name { "Lapsed Golfers" }
      filter_criteria { { "last_booking_before_days" => 90 } }
    end
  end
end
