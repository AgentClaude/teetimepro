# frozen_string_literal: true

FactoryBot.define do
  factory :email_template do
    association :organization
    association :created_by, factory: :user
    name { "#{Faker::Marketing.buzzwords.capitalize} Template" }
    subject { "{{first_name}}, #{Faker::Marketing.buzzwords}!" }
    body_html { "<h1>Hello {{first_name}}</h1><p>#{Faker::Lorem.paragraph}</p>" }
    body_text { "Hello {{first_name}}\n\n#{Faker::Lorem.paragraph}" }
    category { "general" }
    is_active { true }
    merge_fields { EmailTemplate::STANDARD_MERGE_FIELDS }
    usage_count { 0 }

    trait :re_engagement do
      category { "re-engagement" }
      name { "Re-engagement Template" }
      subject { "We miss you, {{first_name}}!" }
      body_html { "<h1>Come back, {{first_name}}</h1><p>It's been a while since your last round.</p>" }
    end

    trait :promotion do
      category { "promotion" }
      name { "Promotion Template" }
      subject { "Special offer for {{first_name}}!" }
      body_html { "<h1>Exclusive Deal</h1><p>Hi {{first_name}}, check out our latest offer.</p>" }
    end

    trait :newsletter do
      category { "newsletter" }
      name { "Newsletter Template" }
      subject { "{{organization_name}} Newsletter" }
    end

    trait :inactive do
      is_active { false }
    end

    trait :popular do
      usage_count { rand(10..100) }
    end
  end
end
