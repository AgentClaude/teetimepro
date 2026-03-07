FactoryBot.define do
  factory :voice_call_log do
    association :organization
    association :course, factory: :course
    
    sequence(:call_sid) { |n| "CA#{SecureRandom.hex(16)}#{n}" }
    channel { "twilio" }
    caller_phone { "+15551234567" }
    caller_name { "John Doe" }
    status { "completed" }
    duration_seconds { 120 }
    transcript { [] }
    summary { {} }
    started_at { Time.current }
    ended_at { 2.minutes.from_now }

    trait :browser do
      channel { "browser" }
    end

    trait :in_progress do
      status { "in_progress" }
      ended_at { nil }
    end

    trait :error do
      status { "error" }
      ended_at { Time.current }
    end

    trait :with_transcript do
      transcript do
        [
          { "type" => "transcript", "role" => "user", "content" => "Hi, I'd like to book a tee time" },
          { "type" => "transcript", "role" => "agent", "content" => "I'd be happy to help you with that" },
          { "type" => "function_call", "name" => "search_tee_times", "arguments" => { "date" => "2023-06-15", "players" => 2 } }
        ]
      end
    end

    trait :with_booking do
      transcript do
        [
          { "type" => "function_result", "name" => "create_booking", "result" => { "success" => true, "confirmation_code" => "ABC123" } }
        ]
      end
      summary { { "booking_created" => true, "confirmation_code" => "ABC123" } }
    end
  end
end