FactoryBot.define do
  factory :round do
    golfer_profile
    course_name { "Pine Valley Golf Club" }
    played_on { Date.current }
    score { 85 }
    holes_played { 18 }
    course_rating { 72.5 }
    slope_rating { 130 }
    tee_color { "white" }

    trait :nine_holes do
      holes_played { 9 }
      score { 42 }
    end

    trait :with_stats do
      putts { 32 }
      fairways_hit { 8 }
      greens_in_regulation { 10 }
    end

    trait :without_rating do
      course_rating { nil }
      slope_rating { nil }
    end
  end
end
