module Types
  class VoiceCallLogType < Types::BaseObject
    field :id, ID, null: false
    field :course_id, ID, null: true
    field :course_name, String, null: true
    field :call_sid, String, null: true
    field :channel, String, null: false
    field :caller_phone, String, null: true
    field :caller_name, String, null: true
    field :status, String, null: false
    field :duration_seconds, Integer, null: true
    field :transcript, GraphQL::Types::JSON, null: false
    field :summary, GraphQL::Types::JSON, null: false
    field :started_at, GraphQL::Types::ISO8601DateTime, null: false
    field :ended_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def course_name
      object.course&.name
    end
  end
end
