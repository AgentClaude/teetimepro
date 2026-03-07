module Mutations
  class UpdateVoiceHandoff < BaseMutation
    argument :id, ID, required: true
    argument :status, Types::VoiceHandoffStatusEnum, required: true
    argument :staff_name, String, required: false
    argument :resolution_notes, String, required: false
    argument :wait_seconds, Integer, required: false

    field :voice_handoff, Types::VoiceHandoffType, null: true
    field :errors, [String], null: false

    def resolve(id:, status:, staff_name: nil, resolution_notes: nil, wait_seconds: nil)
      require_auth!
      require_role!(:staff)

      handoff = current_organization.voice_handoffs.find(id)
      
      result = Voice::UpdateHandoffService.call(
        handoff: handoff,
        status: status,
        staff_name: staff_name,
        resolution_notes: resolution_notes,
        wait_seconds: wait_seconds
      )

      if result.success?
        {
          voice_handoff: result.handoff,
          errors: []
        }
      else
        {
          voice_handoff: nil,
          errors: result.errors
        }
      end
    end
  end
end