FactoryBot.define do
  factory :call_transcription do
    organization
    call_recording
    transcription_text { "Hello, thank you for calling TeeTimes Pro. How can I help you today?" }
    confidence_score { 0.85 }
    language { 'en' }
    provider { 'deepgram' }
    status { 'completed' }
    word_count { 12 }
    duration_seconds { 120 }
    raw_response { 
      {
        "results" => {
          "channels" => [
            {
              "alternatives" => [
                {
                  "transcript" => "Hello, thank you for calling TeeTimes Pro. How can I help you today?",
                  "confidence" => 0.85
                }
              ]
            }
          ]
        }
      }
    }

    trait :with_voice_call_log do
      voice_call_log
    end

    trait :pending do
      status { 'pending' }
      transcription_text { '' }
      confidence_score { 0.0 }
      word_count { 0 }
    end

    trait :processing do
      status { 'processing' }
      transcription_text { '' }
      confidence_score { 0.0 }
      word_count { 0 }
    end

    trait :failed do
      status { 'failed' }
      transcription_text { '' }
      confidence_score { 0.0 }
      word_count { 0 }
    end

    trait :high_confidence do
      confidence_score { 0.95 }
    end

    trait :medium_confidence do
      confidence_score { 0.75 }
    end

    trait :low_confidence do
      confidence_score { 0.45 }
    end

    trait :long_transcript do
      transcription_text { 
        "Hello thank you for calling TeeTimes Pro golf course how can I help you today. I'd like to make a tee time reservation for this weekend please. Of course I can help you with that what day and time were you looking for specifically. Saturday morning around nine o'clock would be perfect for four players. Let me check our availability for Saturday at nine AM for four players. I have a slot available at nine fifteen AM would that work for your group. Yes that sounds great let me book that tee time please."
      }
      word_count { 75 }
    end
  end
end