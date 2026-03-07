FactoryBot.define do
  factory :call_recording do
    organization
    call_sid { "CA#{SecureRandom.hex(16)}" }
    recording_sid { "RE#{SecureRandom.hex(16)}" }
    recording_url { "https://api.twilio.com/recordings/sample.wav" }
    duration_seconds { 120 }
    status { 'completed' }
    file_size_bytes { 2048000 }
    format { 'wav' }

    trait :with_voice_call_log do
      voice_call_log
    end

    trait :pending do
      status { 'pending' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :failed do
      status { 'failed' }
    end

    trait :short_call do
      duration_seconds { 30 }
    end

    trait :long_call do
      duration_seconds { 600 }
    end
  end
end