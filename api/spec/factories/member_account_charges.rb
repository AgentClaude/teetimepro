FactoryBot.define do
  factory :member_account_charge do
    organization
    membership
    charged_by factory: %i[user staff]

    charge_type { 'fnb' }
    status { 'posted' }
    amount_cents { 25_00 }
    description { "F&B Tab - Test Golfer" }
    posted_at { Time.current }

    trait :pending do
      status { 'pending' }
      posted_at { nil }
    end

    trait :voided do
      status { 'voided' }
      voided_at { Time.current }
    end

    trait :pro_shop do
      charge_type { 'pro_shop' }
      description { "Pro shop purchase" }
    end

    trait :booking do
      charge_type { 'booking' }
      description { "Tee time booking" }
    end

    trait :dues do
      charge_type { 'dues' }
      description { "Monthly membership dues" }
      amount_cents { 250_00 }
    end
  end
end
