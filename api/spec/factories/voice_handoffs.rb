FactoryBot.define do
  factory :voice_handoff do
    association :organization
    association :voice_call_log, factory: :voice_call_log
    
    sequence(:call_sid) { |n| "CA#{SecureRandom.hex(16)}#{n}" }
    caller_phone { "+15551234567" }
    caller_name { "John Doe" }
    reason { "billing_inquiry" }
    reason_detail { "Customer wants to dispute a charge on their last booking." }
    status { "pending" }
    transfer_to { "+15559876543" }
    started_at { Time.current }

    trait :pending do
      status { "pending" }
      connected_at { nil }
      completed_at { nil }
      staff_name { nil }
      resolution_notes { nil }
    end

    trait :connected do
      status { "connected" }
      connected_at { 1.minute.ago }
      staff_name { "Manager Smith" }
      wait_seconds { 60 }
    end

    trait :completed do
      status { "completed" }
      connected_at { 5.minutes.ago }
      completed_at { 1.minute.ago }
      staff_name { "Manager Smith" }
      wait_seconds { 45 }
      resolution_notes { "Issue resolved. Customer refund processed." }
    end

    trait :missed do
      status { "missed" }
      completed_at { 1.minute.ago }
      resolution_notes { "No staff available to take the call." }
    end

    trait :cancelled do
      status { "cancelled" }
      completed_at { 1.minute.ago }
      resolution_notes { "Customer hung up before transfer completed." }
    end

    trait :complaint do
      reason { "complaint" }
      reason_detail { "Customer is unhappy with the course conditions and service quality." }
    end

    trait :group_event do
      reason { "group_event" }
      reason_detail { "Customer wants to book a corporate event for 25 players." }
    end

    trait :tournament do
      reason { "tournament" }
      reason_detail { "Customer has questions about upcoming member tournament registration." }
    end

    trait :manager_request do
      reason { "manager_request" }
      reason_detail { "Customer specifically asked to speak with a manager." }
    end

    trait :other do
      reason { "other" }
      reason_detail { "Customer has a complex request that the AI couldn't handle." }
    end

    trait :without_call_log do
      voice_call_log { nil }
    end

    trait :international_caller do
      caller_phone { "+441234567890" }
      caller_name { "Jane Smith" }
    end
  end
end