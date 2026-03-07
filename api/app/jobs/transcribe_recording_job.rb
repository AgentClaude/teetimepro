class TranscribeRecordingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(call_recording_id)
    call_recording = CallRecording.find(call_recording_id)
    
    Rails.logger.info "Starting transcription job for recording: #{call_recording_id}"
    
    result = Recordings::TranscribeService.call(call_recording: call_recording)
    
    if result.success?
      Rails.logger.info "Successfully transcribed recording: #{call_recording_id}"
    else
      Rails.logger.error "Failed to transcribe recording #{call_recording_id}: #{result.error_messages}"
      raise StandardError, "Transcription failed: #{result.error_messages}"
    end
  end
end