FactoryBot.define do
  factory :handicap_revision do
    golfer_profile
    handicap_index { 15.0 }
    previous_index { 15.5 }
    rounds_used { 5 }
    effective_date { Date.current }
    source { "calculated" }
  end
end
