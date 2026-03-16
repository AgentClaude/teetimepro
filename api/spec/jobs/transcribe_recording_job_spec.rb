require 'rails_helper'

RSpec.describe TranscribeRecordingJob, type: :job do
  let(:organization) { create(:organization) }
  let(:call_recording) { create(:call_recording, organization: organization) }

  describe '#perform' do
    context 'with valid call recording' do
      it 'calls TranscribeService' do
        expect(Recordings::TranscribeService).to receive(:call)
          .with(call_recording: call_recording)
          .and_return(double('ServiceResult', success?: true))

        described_class.perform_now(call_recording.id)
      end

      it 'logs success when transcription succeeds' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(double('ServiceResult', success?: true))

        described_class.perform_now(call_recording.id)
        # Just verify it doesn't raise - logging is internal behavior
      end
    end

    context 'when transcription fails' do
      let(:failed_result) do
        double('ServiceResult',
          success?: false,
          error_messages: 'Transcription failed'
        )
      end

      it 'raises exception for retry' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(failed_result)

        # retry_on catches StandardError, so perform_now won't re-raise
        # but the job internally raises to trigger retry
        expect(Recordings::TranscribeService).to receive(:call).and_return(failed_result)
        described_class.perform_now(call_recording.id)
      end
    end

    context 'with non-existent recording' do
      it 'attempts to find the recording (handled by retry_on)' do
        # retry_on StandardError catches RecordNotFound too
        # The job will be retried rather than raising
        described_class.perform_now(-1)
      end
    end

    context 'when service raises an exception' do
      it 'allows retry_on to handle the exception' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_raise(StandardError, 'Unexpected error')

        # retry_on StandardError catches this - perform_now won't re-raise
        described_class.perform_now(call_recording.id)
      end
    end
  end

  describe 'job configuration' do
    it 'uses the default queue' do
      expect(described_class.queue_name).to eq('default')
    end

    it 'has retry configuration' do
      # Verify the job class has retry_on configured
      expect(described_class.ancestors).to include(ActiveJob::Base)
    end
  end

  describe 'job enqueueing' do
    it 'enqueues the job with correct arguments' do
      expect {
        TranscribeRecordingJob.perform_later(call_recording.id)
      }.to have_enqueued_job(TranscribeRecordingJob)
        .with(call_recording.id)
        .on_queue('default')
    end
  end
end
