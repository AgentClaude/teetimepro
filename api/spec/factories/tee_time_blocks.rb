# frozen_string_literal: true

FactoryBot.define do
  factory :tee_time_block do
    organization
    course { association :course, organization: organization }
    created_by { association :user, organization: organization }
    block_type { :maintenance }
    reason { "Greens maintenance" }
    description { "Scheduled aeration and reseeding of greens" }
    starts_at { 1.day.from_now.beginning_of_day + 6.hours }
    ends_at { 1.day.from_now.beginning_of_day + 10.hours }
    active { true }
    recurring { false }

    trait :event do
      block_type { :event }
      reason { "Club tournament" }
      description { "Annual club championship - course closed to public" }
    end

    trait :weather do
      block_type { :weather }
      reason { "Severe weather warning" }
      description { "Course closed due to lightning risk" }
    end

    trait :other do
      block_type { :other }
      reason { "Private rental" }
    end

    trait :inactive do
      active { false }
    end

    trait :past do
      starts_at { 2.days.ago }
      ends_at { 1.day.ago }
    end

    trait :current do
      starts_at { 1.hour.ago }
      ends_at { 3.hours.from_now }
    end

    trait :future do
      starts_at { 2.days.from_now.beginning_of_day + 6.hours }
      ends_at { 2.days.from_now.beginning_of_day + 10.hours }
    end
  end
end
