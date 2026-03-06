FactoryBot.define do
  factory :tournament_entry do
    tournament
    user
    status { :registered }
    handicap_index { rand(0.0..36.0).round(1) }

    trait :confirmed do
      status { :confirmed }
    end

    trait :withdrawn do
      status { :withdrawn }
    end

    trait :with_team do
      team_name { "Team #{Faker::Sports::Football.team}" }
    end
  end
end
