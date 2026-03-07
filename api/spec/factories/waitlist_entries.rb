# frozen_string_literal: true

FactoryBot.define do
  factory :waitlist_entry do
    user
    tee_time
    organization { tee_time&.tee_sheet&.course&.organization || association(:organization) }
    players_requested { 2 }
    status { :waiting }

    trait :notified do
      status { :notified }
      notified_at { Time.current }
    end

    trait :expired do
      status { :expired }
      expired_at { Time.current }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
