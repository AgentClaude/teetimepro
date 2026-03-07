module Types
  class CallRecordingType < Types::BaseObject
    field :id, ID, null: false
    field :organization, Types::OrganizationType, null: false
    field :voice_call_log, Types::VoiceCallLogType, null: true
    field :call_sid, String, null: false
    field :recording_sid, String, null: false
    field :recording_url, String, null: false
    field :duration_seconds, Integer, null: false
    field :status, String, null: false
    field :file_size_bytes, GraphQL::Types::BigInt, null: true
    field :format, String, null: false
    field :transcribed, Boolean, null: false
    field :latest_transcription, Types::CallTranscriptionType, null: true
    field :call_transcriptions, [Types::CallTranscriptionType], null: false
    field :formatted_duration, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def transcribed
      object.transcribed?
    end

    def formatted_duration
      minutes = object.duration_seconds / 60
      seconds = object.duration_seconds % 60
      "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
    end
  end
end