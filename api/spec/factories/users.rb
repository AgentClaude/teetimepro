FactoryBot.define do
  factory :user do
    organization
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { :golfer }

    trait :staff do
      role { :staff }
    end

    trait :pro_shop do
      role { :pro_shop }
    end

    trait :manager do
      role { :manager }
    end

    trait :admin do
      role { :admin }
    end

    trait :owner do
      role { :owner }
    end

    trait :with_profile do
      after(:create) do |user|
        create(:golfer_profile, user: user)
      end
    end
  end
end
