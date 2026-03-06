FactoryBot.define do
  factory :tournament do
    organization
    course
    association :created_by, factory: :user
    name { "#{Faker::Sports::Football.competition} Golf Tournament" }
    description { "Annual tournament at #{course.name}" }
    format { :stroke }
    status { :draft }
    start_date { 2.weeks.from_now.to_date }
    end_date { 2.weeks.from_now.to_date }
    max_participants { 72 }
    min_participants { 8 }
    team_size { 1 }
    entry_fee_cents { 5000 }
    entry_fee_currency { "USD" }
    holes { 18 }
    handicap_enabled { true }
    max_handicap { 36.0 }
    rules { {} }
    prize_structure { {} }

    trait :registration_open do
      status { :registration_open }
      registration_opens_at { 1.week.ago }
      registration_closes_at { 1.week.from_now }
    end

    trait :scramble do
      format { :scramble }
      team_size { 4 }
    end

    trait :best_ball do
      format { :best_ball }
      team_size { 2 }
    end

    trait :match_play do
      format { :match_play }
      team_size { 1 }
    end

    trait :in_progress do
      status { :in_progress }
      start_date { Date.current }
      end_date { Date.current }
    end

    trait :completed do
      status { :completed }
      start_date { 1.week.ago.to_date }
      end_date { 1.week.ago.to_date }
    end

    trait :free do
      entry_fee_cents { 0 }
    end

    trait :with_prizes do
      prize_structure do
        {
          "1st" => { "amount_cents" => 50000, "description" => "First Place" },
          "2nd" => { "amount_cents" => 25000, "description" => "Second Place" },
          "3rd" => { "amount_cents" => 10000, "description" => "Third Place" }
        }
      end
    end
  end
end
