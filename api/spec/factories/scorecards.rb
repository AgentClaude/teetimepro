FactoryBot.define do
  factory :scorecard do
    golfer_profile
    course
    played_on { Date.current }
    holes_played { 18 }
    status { "in_progress" }
    tee_color { "white" }
    started_at { Time.current }

    trait :completed do
      status { "completed" }
      total_strokes { 82 }
      total_putts { 32 }
      total_fairways_hit { 8 }
      total_greens_in_regulation { 10 }
      total_penalties { 2 }
      front_nine_strokes { 40 }
      back_nine_strokes { 42 }
      score_to_par { 10 }
      completed_at { Time.current }
    end

    trait :abandoned do
      status { "abandoned" }
    end

    trait :nine_holes do
      holes_played { 9 }
    end

    trait :with_hole_scores do
      after(:create) do |scorecard|
        pars = [4, 4, 3, 4, 5, 4, 3, 4, 5] * (scorecard.holes_played / 9)
        pars.each_with_index do |par, i|
          create(:hole_score, scorecard: scorecard, hole_number: i + 1, par: par)
        end
      end
    end

    trait :with_scored_holes do
      after(:create) do |scorecard|
        pars = [4, 4, 3, 4, 5, 4, 3, 4, 5] * (scorecard.holes_played / 9)
        pars.each_with_index do |par, i|
          create(:hole_score, :scored, scorecard: scorecard, hole_number: i + 1, par: par)
        end
        scorecard.recalculate_totals!
      end
    end
  end
end
