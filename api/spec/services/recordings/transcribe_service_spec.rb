require 'rails_helper'

RSpec.describe Recordings::TranscribeService, type: :service do
  let(:organization) { create(:organization) }
  let(:call_recording) { create(:call_recording, organization: organization) }

  describe '.call' do
    context 'with valid call recording' do
      it 'creates a new transcription' do
        expect {
          result = described_class.call(call_recording: call_recording)
          expect(result).to be_success
        }.to change(CallTranscription, :count).by(1)
      end

      it 'sets transcription attributes correctly' do
        result = described_class.call(call_recording: call_recording)

        transcription = result.transcription
        expect(transcription.organization).to eq(organization)
        expect(transcription.call_recording).to eq(call_recording)
        expect(transcription.transcription_text).to be_present
        expect(transcription.confidence_score).to be > 0
        expect(transcription.provider).to eq('deepgram')
        expect(transcription.status).to eq('completed')
        expect(transcription.duration_seconds).to eq(call_recording.duration_seconds)
        expect(transcription.word_count).to be > 0
      end

      it 'stores raw API response' do
        result = described_class.call(call_recording: call_recording)

        transcription = result.transcription
        expect(transcription.raw_response).to be_present
        expect(transcription.raw_response['results']).to be_present
        expect(transcription.raw_response['metadata']).to be_present
      end

      context 'with voice_call_log' do
        let(:voice_call_log) { create(:voice_call_log, organization: organization) }
        let(:call_recording) { create(:call_recording, organization: organization, voice_call_log: voice_call_log) }

        it 'associates transcription with voice_call_log' do
          result = described_class.call(call_recording: call_recording)

          transcription = result.transcription
          expect(transcription.voice_call_log).to eq(voice_call_log)
        end
      end
    end

    context 'with missing call recording' do
      it 'returns validation failure' do
        result = described_class.call(call_recording: nil)

        expect(result).to be_failure
        expect(result.errors).to include(match(/Call recording can't be blank/))
      end
    end

    context 'when transcription creation fails' do
      it 'returns failure and marks transcription as failed' do
        allow_any_instance_of(CallTranscription).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

        result = described_class.call(call_recording: call_recording)

        expect(result).to be_failure
      end
    end

    context 'when API call fails' do
      it 'marks transcription as failed and returns failure' do
        service = described_class.new(call_recording: call_recording)
        allow(service).to receive(:call_deepgram_api!).and_raise(StandardError, 'API Error')

        result = service.call

        expect(result).to be_failure
        expect(result.errors).to include(match(/Failed to transcribe recording: API Error/))
      end
    end

    context 'when API returns invalid response' do
      it 'handles malformed response gracefully' do
        service = described_class.new(call_recording: call_recording)
        allow(service).to receive(:call_deepgram_api!).and_return(nil)
        allow(service).to receive(:process_transcription_response!).and_raise(StandardError, 'Invalid response')

        result = service.call

        expect(result).to be_failure
      end
    end

    describe 'mock API response' do
      it 'generates realistic transcript content' do
        result = described_class.call(call_recording: call_recording)

        transcription = result.transcription
        expect(transcription.transcription_text).to include('TeeTimes Pro')
        expect(transcription.transcription_text.split.length).to be > 5
        expect(transcription.confidence_score).to be_between(0.8, 1.0)
      end

      it 'includes proper metadata in raw response' do
        result = described_class.call(call_recording: call_recording)

        raw_response = result.transcription.raw_response
        expect(raw_response['metadata']['request_id']).to be_present
        expect(raw_response['metadata']['duration']).to eq(call_recording.duration_seconds)
        expect(raw_response['metadata']['created']).to be_present
      end
    end

    describe 'in test environment' do
      it 'uses mock response' do
        result = described_class.call(call_recording: call_recording)

        expect(result).to be_success
        transcription = result.transcription
        expect(transcription.transcription_text).to be_present
        expect(transcription.provider).to eq('deepgram')
      end
    end
  end

  describe '#mock_deepgram_response' do
    let(:service) { described_class.new(call_recording: call_recording) }

    it 'returns properly structured response' do
      response = service.send(:mock_deepgram_response)

      expect(response).to have_key('results')
      expect(response).to have_key('metadata')
      expect(response['results']['channels']).to be_an(Array)
      expect(response['results']['channels'][0]['alternatives']).to be_an(Array)
      
      alternative = response['results']['channels'][0]['alternatives'][0]
      expect(alternative).to have_key('transcript')
      expect(alternative).to have_key('confidence')
      expect(alternative['confidence']).to be_a(Numeric)
    end
  end
end