module Types
  class VoiceHandoffType < Types::BaseObject
    field :id, ID, null: false
    field :organization_id, ID, null: false
    field :voice_call_log_id, ID, null: true
    field :voice_call_log, VoiceCallLogType, null: true
    
    field :call_sid, String, null: false
    field :caller_phone, String, null: false
    field :caller_name, String, null: true
    field :reason, VoiceHandoffReasonEnum, null: false
    field :reason_detail, String, null: true
    field :status, VoiceHandoffStatusEnum, null: false
    field :transfer_to, String, null: false
    field :staff_name, String, null: true
    field :wait_seconds, Integer, null: true
    field :resolution_notes, String, null: true
    
    field :started_at, GraphQL::Types::ISO8601DateTime, null: false
    field :connected_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Computed fields
    field :formatted_caller_phone, String, null: false
    field :caller_display_name, String, null: false
    field :duration_seconds, Integer, null: true
    field :wait_duration_seconds, Integer, null: true
    field :active, Boolean, null: false

    def formatted_caller_phone
      object.formatted_caller_phone
    end

    def caller_display_name
      object.caller_display_name
    end

    def duration_seconds
      object.duration_seconds&.to_i
    end

    def wait_duration_seconds
      object.wait_duration_seconds&.to_i
    end

    def active
      object.active?
    end
  end
end