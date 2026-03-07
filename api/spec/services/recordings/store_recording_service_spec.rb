require 'rails_helper'

RSpec.describe Recordings::StoreRecordingService, type: :service do
  let(:organization) { create(:organization) }
  let(:voice_call_log) { create(:voice_call_log, organization: organization) }
  let(:webhook_data) do
    {
      'CallSid' => voice_call_log.call_sid,
      'RecordingSid' => 'RE1234567890abcdef',
      'RecordingUrl' => 'https://api.twilio.com/recordings/sample.wav',
      'RecordingDuration' => '120',
      'RecordingSize' => '2048000'
    }
  end

  describe '.call' do
    context 'with valid data' do
      it 'creates a new call recording' do
        expect {
          result = described_class.call(
            webhook_data: webhook_data,
            organization: organization
          )
          expect(result).to be_success
        }.to change(CallRecording, :count).by(1)
      end

      it 'sets recording attributes correctly' do
        result = described_class.call(
          webhook_data: webhook_data,
          organization: organization
        )

        recording = result.recording
        expect(recording.call_sid).to eq(webhook_data['CallSid'])
        expect(recording.recording_sid).to eq(webhook_data['RecordingSid'])
        expect(recording.recording_url).to eq(webhook_data['RecordingUrl'])
        expect(recording.duration_seconds).to eq(120)
        expect(recording.file_size_bytes).to eq(2048000)
        expect(recording.status).to eq('completed')
        expect(recording.voice_call_log).to eq(voice_call_log)
      end

      it 'enqueues transcription job' do
        expect(TranscribeRecordingJob).to receive(:perform_later)

        described_class.call(
          webhook_data: webhook_data,
          organization: organization
        )
      end
    end

    context 'when updating existing recording' do
      let!(:existing_recording) do
        create(:call_recording, 
          recording_sid: webhook_data['RecordingSid'],
          organization: organization,
          status: 'pending'
        )
      end

      it 'updates existing recording instead of creating new one' do
        expect {
          result = described_class.call(
            webhook_data: webhook_data,
            organization: organization
          )
          expect(result).to be_success
        }.not_to change(CallRecording, :count)

        existing_recording.reload
        expect(existing_recording.status).to eq('completed')
        expect(existing_recording.recording_url).to eq(webhook_data['RecordingUrl'])
      end
    end

    context 'with missing webhook data' do
      let(:invalid_webhook_data) { {} }

      it 'returns failure' do
        result = described_class.call(
          webhook_data: invalid_webhook_data,
          organization: organization
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/Missing required webhook data/))
      end
    end

    context 'with missing organization' do
      it 'returns validation failure' do
        result = described_class.call(
          webhook_data: webhook_data,
          organization: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/Organization can't be blank/))
      end
    end

    context 'when call_sid does not match any voice_call_log' do
      let(:webhook_data_no_match) do
        webhook_data.merge('CallSid' => 'UNKNOWN_CALL_SID')
      end

      it 'creates recording without voice_call_log association' do
        result = described_class.call(
          webhook_data: webhook_data_no_match,
          organization: organization
        )

        expect(result).to be_success
        expect(result.recording.voice_call_log).to be_nil
        expect(result.recording.call_sid).to eq('UNKNOWN_CALL_SID')
      end
    end

    context 'when database save fails' do
      it 'returns failure' do
        allow_any_instance_of(CallRecording).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

        result = described_class.call(
          webhook_data: webhook_data,
          organization: organization
        )

        expect(result).to be_failure
      end
    end
  end
end