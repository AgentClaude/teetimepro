module Mutations
  class InitiateVoiceHandoff < BaseMutation
    argument :call_sid, String, required: true
    argument :caller_phone, String, required: true
    argument :caller_name, String, required: false
    argument :reason, Types::VoiceHandoffReasonEnum, required: true
    argument :reason_detail, String, required: false
    argument :voice_call_log_id, ID, required: false

    field :voice_handoff, Types::VoiceHandoffType, null: true
    field :transfer_number, String, null: true
    field :already_exists, Boolean, null: false
    field :errors, [String], null: false

    def resolve(call_sid:, caller_phone:, reason:, caller_name: nil, reason_detail: nil, voice_call_log_id: nil)
      require_auth!
      require_role!(:staff)

      result = Voice::InitiateHandoffService.call(
        organization: current_organization,
        call_sid: call_sid,
        caller_phone: caller_phone,
        caller_name: caller_name,
        reason: reason,
        reason_detail: reason_detail,
        voice_call_log_id: voice_call_log_id
      )

      if result.success?
        {
          voice_handoff: result.handoff,
          transfer_number: result.transfer_number,
          already_exists: result.already_exists || false,
          errors: []
        }
      else
        {
          voice_handoff: nil,
          transfer_number: nil,
          already_exists: false,
          errors: result.errors
        }
      end
    end
  end
end