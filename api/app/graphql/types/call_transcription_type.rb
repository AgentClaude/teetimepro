module Types
  class CallTranscriptionType < Types::BaseObject
    field :id, ID, null: false
    field :organization, Types::OrganizationType, null: false
    field :call_recording, Types::CallRecordingType, null: false
    field :voice_call_log, Types::VoiceCallLogType, null: true
    field :transcription_text, String, null: false
    field :confidence_score, Float, null: false
    field :language, String, null: false
    field :provider, String, null: false
    field :raw_response, GraphQL::Types::JSON, null: true
    field :status, String, null: false
    field :word_count, Integer, null: false
    field :duration_seconds, Integer, null: false
    field :high_confidence, Boolean, null: false
    field :medium_confidence, Boolean, null: false
    field :low_confidence, Boolean, null: false
    field :formatted_duration, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def high_confidence
      object.high_confidence?
    end

    def medium_confidence
      object.medium_confidence?
    end

    def low_confidence
      object.low_confidence?
    end

    def formatted_duration
      object.formatted_duration
    end
  end
end