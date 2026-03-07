FactoryBot.define do
  factory :tournament_entry do
    tournament
    user
    status { :registered }
    handicap_index { rand(0.0..36.0).round(1) }

    # Temporarily open registration if tournament isn't accepting registrations
    before(:create) do |entry|
      tournament = entry.tournament
      unless tournament.registration_open?
        original_status = tournament.status
        tournament.update_column(:status, Tournament.statuses[:registration_open])
        entry.instance_variable_set(:@_original_tournament_status, original_status)
      end
    end

    after(:create) do |entry|
      original_status = entry.instance_variable_get(:@_original_tournament_status)
      if original_status
        entry.tournament.update_column(:status, Tournament.statuses[original_status.to_sym] || original_status)
      end
    end

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
