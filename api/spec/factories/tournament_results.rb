FactoryBot.define do
  factory :tournament_result do
    tournament
    tournament_entry
    position { 1 }
    total_strokes { 72 }
    total_to_par { 0 }
    tied { false }
    prize_awarded { false }
    finalized_at { Time.current }

    trait :winner do
      position { 1 }
      total_strokes { 69 }
      total_to_par { -3 }
      prize_awarded { true }
    end

    trait :runner_up do
      position { 2 }
      total_strokes { 71 }
      total_to_par { -1 }
      prize_awarded { true }
    end

    trait :third_place do
      position { 3 }
      total_strokes { 72 }
      total_to_par { 0 }
      prize_awarded { true }
    end

    trait :tied_for_first do
      position { 1 }
      tied { true }
      total_strokes { 70 }
      total_to_par { -2 }
    end

    trait :tied_for_second do
      position { 2 }
      tied { true }
      total_strokes { 72 }
      total_to_par { 0 }
    end

    trait :out_of_money do
      position { 10 }
      total_strokes { 80 }
      total_to_par { 8 }
      prize_awarded { false }
    end

    trait :not_finalized do
      finalized_at { nil }
    end

    # Ensure tournament_entry belongs to the same tournament
    before(:create) do |result, evaluator|
      if result.tournament_entry&.tournament != result.tournament
        result.tournament_entry = create(:tournament_entry, tournament: result.tournament)
      end
    end
  end
end