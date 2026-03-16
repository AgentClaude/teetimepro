FactoryBot.define do
  factory :course_gps_feature do
    course_hole
    feature_type { :green_center }
    name { "Green Center" }
    latitude { 33.4484 + rand(-0.01..0.01) }
    longitude { -112.0740 + rand(-0.01..0.01) }
    elevation_feet { nil }
    distance_from_tee_yards { nil }
    metadata { {} }

    trait :tee_box do
      feature_type { :tee_box }
      name { "Tee Box" }
      distance_from_tee_yards { 0 }
    end

    trait :green_front do
      feature_type { :green_front }
      name { "Front of Green" }
    end

    trait :green_back do
      feature_type { :green_back }
      name { "Back of Green" }
    end

    trait :bunker do
      feature_type { :bunker }
      name { "Greenside Bunker" }
    end

    trait :water_hazard do
      feature_type { :water_hazard }
      name { "Water Hazard" }
    end

    trait :pin_position do
      feature_type { :pin_position }
      name { "Pin Position" }
    end

    trait :with_elevation do
      elevation_feet { rand(100..500).to_f }
    end

    trait :with_distance do
      distance_from_tee_yards { rand(100..550) }
    end
  end
end
