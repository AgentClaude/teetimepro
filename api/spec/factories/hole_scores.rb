FactoryBot.define do
  factory :hole_score do
    scorecard
    sequence(:hole_number) { |n| ((n - 1) % 18) + 1 }
    par { [3, 4, 5].sample }

    trait :scored do
      strokes { par + rand(-1..3) }
      putts { rand(1..3) }
      fairway_hit { [true, false].sample }
      green_in_regulation { [true, false].sample }
      penalties { [0, 0, 0, 1].sample }
    end

    trait :birdie do
      strokes { par - 1 }
      putts { 1 }
    end

    trait :bogey do
      strokes { par + 1 }
      putts { 2 }
    end

    trait :par_score do
      strokes { par }
      putts { 2 }
    end
  end
end
