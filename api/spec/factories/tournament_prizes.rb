FactoryBot.define do
  factory :tournament_prize do
    tournament
    position { 1 }
    prize_type { :cash }
    description { "First Place Prize" }
    amount_cents { 50000 }

    trait :cash do
      prize_type { :cash }
      description { "Cash Prize - #{position.ordinalize} Place" }
    end

    trait :trophy do
      prize_type { :trophy }
      amount_cents { 0 }
      description { "Trophy - #{position.ordinalize} Place" }
    end

    trait :voucher do
      prize_type { :voucher }
      amount_cents { 25000 }
      description { "Pro Shop Voucher - #{position.ordinalize} Place" }
    end

    trait :merchandise do
      prize_type { :merchandise }
      amount_cents { 15000 }
      description { "Golf Equipment - #{position.ordinalize} Place" }
    end

    trait :custom do
      prize_type { :custom }
      amount_cents { 0 }
      description { "Weekend Golf Package - #{position.ordinalize} Place" }
    end

    trait :second_place do
      position { 2 }
      amount_cents { 25000 }
      description { "Second Place Prize" }
    end

    trait :third_place do
      position { 3 }
      amount_cents { 10000 }
      description { "Third Place Prize" }
    end

    trait :awarded do
      after(:create) do |prize|
        entry = create(:tournament_entry, tournament: prize.tournament)
        prize.update!(awarded_to: entry)
      end
    end
  end
end