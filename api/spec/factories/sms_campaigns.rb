FactoryBot.define do
  factory :sms_campaign do
    organization
    association :created_by, factory: [:user, :manager]
    name { "#{Faker::Marketing.buzzwords.capitalize} Campaign" }
    message_body { "Hi! #{Faker::Marketing.buzzwords}. Book your tee time today!" }
    status { :draft }
    recipient_filter { "all" }
    filter_criteria { {} }

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
      delivered_count { 9 }
      failed_count { 1 }
    end

    trait :with_messages do
      after(:create) do |campaign|
        3.times do
          user = create(:user, organization: campaign.organization, phone: Faker::PhoneNumber.cell_phone)
          create(:sms_message, sms_campaign: campaign, user: user)
        end
      end
    end
  end
end
