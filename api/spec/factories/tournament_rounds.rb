FactoryBot.define do
  factory :tournament_round do
    tournament
    round_number { 1 }
    play_date { tournament.start_date }
    status { :not_started }

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end
  end
end
