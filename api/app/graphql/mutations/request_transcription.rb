module Mutations
  class RequestTranscription < BaseMutation
    argument :call_recording_id, ID, required: true

    field :call_recording, Types::CallRecordingType, null: true
    field :transcription, Types::CallTranscriptionType, null: true
    field :errors, [String], null: false

    def resolve(call_recording_id:)
      org = require_auth!

      call_recording = CallRecording.for_organization(org).find(call_recording_id)

      result = Recordings::TranscribeService.call(call_recording: call_recording)

      if result.success?
        {
          call_recording: call_recording.reload,
          transcription: result.transcription,
          errors: []
        }
      else
        { 
          call_recording: nil, 
          transcription: nil, 
          errors: result.errors 
        }
      end
    end
  end
end