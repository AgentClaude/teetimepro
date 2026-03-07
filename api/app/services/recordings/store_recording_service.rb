module Recordings
  class StoreRecordingService < ApplicationService
    attr_accessor :webhook_data, :organization

    validates :webhook_data, presence: true
    validates :organization, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        extract_webhook_data!
        find_or_create_recording!
        enqueue_transcription_if_enabled!
        
        success(recording: @recording)
      rescue => e
        Rails.logger.error "Failed to store recording: #{e.message}"
        failure(errors: ["Failed to store recording: #{e.message}"])
      end
    end

    private

    def extract_webhook_data!
      @call_sid = webhook_data['CallSid']
      @recording_sid = webhook_data['RecordingSid']
      @recording_url = webhook_data['RecordingUrl']
      @duration = webhook_data['RecordingDuration']&.to_i || 0
      @file_size = webhook_data['RecordingSize']&.to_i

      unless @call_sid && @recording_sid && @recording_url && @duration > 0
        raise ArgumentError, "Missing required webhook data: CallSid, RecordingSid, RecordingUrl, or Duration"
      end
    end

    def find_or_create_recording!
      # Find existing voice call log if available
      voice_call_log = organization.voice_call_logs.find_by(call_sid: @call_sid)

      @recording = organization.call_recordings.find_or_initialize_by(
        recording_sid: @recording_sid
      )

      if @recording.new_record?
        @recording.assign_attributes(
          call_sid: @call_sid,
          voice_call_log: voice_call_log,
          recording_url: @recording_url,
          duration_seconds: @duration,
          file_size_bytes: @file_size,
          status: 'completed'
        )
        
        @recording.save!
        Rails.logger.info "Created new call recording: #{@recording.id}"
      else
        # Update existing recording if it was pending
        @recording.update!(
          recording_url: @recording_url,
          duration_seconds: @duration,
          file_size_bytes: @file_size,
          status: 'completed'
        )
        Rails.logger.info "Updated existing call recording: #{@recording.id}"
      end
    end

    def enqueue_transcription_if_enabled!
      # Check if auto-transcription is enabled for this organization
      # For now, we'll always enqueue transcription
      TranscribeRecordingJob.perform_later(@recording.id)
      Rails.logger.info "Enqueued transcription job for recording: #{@recording.id}"
    end
  end
end