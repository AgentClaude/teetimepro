FactoryBot.define do
  factory :tournament_score do
    tournament_round
    tournament_entry
    hole_number { 1 }
    strokes { 4 }
    par { 4 }
    putts { 2 }
    fairway_hit { true }
    green_in_regulation { true }

    trait :birdie do
      strokes { 3 }
      par { 4 }
    end

    trait :eagle do
      strokes { 3 }
      par { 5 }
    end

    trait :bogey do
      strokes { 5 }
      par { 4 }
    end

    trait :double_bogey do
      strokes { 6 }
      par { 4 }
    end
  end
end
