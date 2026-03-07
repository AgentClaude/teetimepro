FactoryBot.define do
  factory :email_campaign do
    organization
    association :created_by, factory: [:user, :manager]
    name { "#{Faker::Marketing.buzzwords.capitalize} Email Campaign" }
    subject { "We miss you at #{Faker::Company.name}!" }
    body_html { "<p>Hi {{first_name}},</p><p>#{Faker::Marketing.buzzwords}</p>" }
    body_text { "Hi {{first_name}}, #{Faker::Marketing.buzzwords}" }
    status { :draft }
    recipient_filter { "all" }
    filter_criteria { {} }
    lapsed_days { 30 }
    is_automated { false }

    trait :scheduled do
      status { :scheduled }
      scheduled_at { 1.hour.from_now }
    end

    trait :sending do
      status { :sending }
      sent_at { Time.current }
      total_recipients { 10 }
    end

    trait :completed do
      status { :completed }
      sent_at { 1.hour.ago }
      completed_at { 30.minutes.ago }
      total_recipients { 10 }
      sent_count { 9 }
      delivered_count { 7 }
      opened_count { 4 }
      clicked_count { 2 }
      failed_count { 1 }
    end

    trait :automated do
      is_automated { true }
      recurrence_interval_days { 7 }
    end

    trait :lapsed_filter do
      recipient_filter { "lapsed" }
      lapsed_days { 60 }
    end

    trait :with_messages do
      after(:create) do |campaign|
        3.times do
          user = create(:user, organization: campaign.organization)
          create(:email_message, email_campaign: campaign, user: user)
        end
      end
    end
  end
end
