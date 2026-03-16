FactoryBot.define do
  factory :player_location do
    booking
    course { booking&.tee_time&.tee_sheet&.course || association(:course) }
    rangefinder_device { nil }
    latitude { 33.4484 + rand(-0.01..0.01) }
    longitude { -112.0740 + rand(-0.01..0.01) }
    accuracy_meters { rand(1.0..15.0).round(2) }
    current_hole { rand(1..18) }
    recorded_at { Time.current }

    trait :with_device do
      rangefinder_device { association(:rangefinder_device, organization: course.organization) }
    end

    trait :stale do
      recorded_at { 2.hours.ago }
    end
  end
end
