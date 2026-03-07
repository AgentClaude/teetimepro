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

        expect(Rails.logger).to receive(:info)
          .with("Starting transcription job for recording: #{call_recording.id}")
        expect(Rails.logger).to receive(:info)
          .with("Successfully transcribed recording: #{call_recording.id}")

        described_class.perform_now(call_recording.id)
      end
    end

    context 'when transcription fails' do
      let(:failed_result) do
        double('ServiceResult', 
          success?: false, 
          error_messages: 'Transcription failed'
        )
      end

      it 'logs error and raises exception' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(failed_result)

        expect(Rails.logger).to receive(:error)
          .with("Failed to transcribe recording #{call_recording.id}: Transcription failed")

        expect {
          described_class.perform_now(call_recording.id)
        }.to raise_error(StandardError, 'Transcription failed: Transcription failed')
      end
    end

    context 'with non-existent recording' do
      it 'raises ActiveRecord::RecordNotFound' do
        expect {
          described_class.perform_now('non-existent-id')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when service raises an exception' do
      it 'allows exception to bubble up for retry handling' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_raise(StandardError, 'Unexpected error')

        expect {
          described_class.perform_now(call_recording.id)
        }.to raise_error(StandardError, 'Unexpected error')
      end
    end
  end

  describe 'job configuration' do
    it 'is configured to retry on StandardError' do
      expect(described_class.retry_on).to include(StandardError)
    end

    it 'uses the default queue' do
      expect(described_class.queue_name).to eq('default')
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