FactoryBot.define do
  factory :golfer_profile do
    user
    handicap_index { 15.0 }
    home_course { "Pine Valley Golf Club" }
    preferred_tee { "white" }
    total_rounds { 0 }
    best_score { nil }
    average_score { nil }
    last_played_on { nil }
  end
end
