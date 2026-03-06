FactoryBot.define do
  factory :organization do
    name { Faker::Company.name + " Golf Club" }
    slug { Faker::Internet.slug(glue: "-") + "-#{SecureRandom.hex(3)}" }
    stripe_account_id { nil }

    trait :with_stripe do
      stripe_account_id { "acct_#{SecureRandom.hex(8)}" }
    end
  end
end
