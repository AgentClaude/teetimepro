FactoryBot.define do
  factory :fnb_tab do
    organization
    course { association :course, organization: organization }
    user { association :user, organization: organization }
    golfer_name { Faker::Name.name }
    status { 'open' }
    total_cents { 0 }
    opened_at { Time.current }
    closed_at { nil }

    trait :closed do
      status { 'closed' }
      closed_at { 1.hour.after(opened_at) }
      total_cents { 2500 }
    end

    trait :merged do
      status { 'merged' }
      closed_at { 30.minutes.after(opened_at) }
    end

    trait :with_items do
      after(:create) do |tab|
        create(:fnb_tab_item, fnb_tab: tab, added_by: tab.user)
        create(:fnb_tab_item, fnb_tab: tab, added_by: tab.user, category: 'beverage')
        tab.reload
      end
    end
  end
end
