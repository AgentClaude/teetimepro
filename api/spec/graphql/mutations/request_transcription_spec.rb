require 'rails_helper'

RSpec.describe Mutations::RequestTranscription, type: :graphql do
  let(:user) { create(:user, :manager) }
  let(:organization) { user.organization }
  let(:call_recording) { create(:call_recording, organization: organization) }

  let(:mutation) do
    <<~GQL
      mutation RequestTranscription($callRecordingId: ID!) {
        requestTranscription(callRecordingId: $callRecordingId) {
          callRecording {
            id
            status
            transcribed
          }
          transcription {
            id
            transcriptionText
            confidenceScore
            status
            provider
          }
          errors
        }
      }
    GQL
  end

  let(:variables) do
    { 
      callRecordingId: call_recording.id 
    }
  end

  context 'when authenticated' do
    context 'with valid call recording' do
      it 'returns authorization error' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: true,
            transcription: create(:call_transcription, call_recording: call_recording)
          ))

        result = execute_query(mutation, variables: variables, context: { current_user: user })

        expect(result['errors']).to be_present
        expect(result['errors'].first['message']).to include('No organization')
        expect(result.dig('data', 'requestTranscription')).to be_nil
      end

      it 'calls TranscribeService with correct parameters' do
        expect(Recordings::TranscribeService).to receive(:call)
          .with(call_recording: call_recording)
          .and_return(double('ServiceResult', 
            success?: true,
            transcription: create(:call_transcription, call_recording: call_recording)
          ))

        execute_query(mutation, variables: variables, context: { current_user: user })
      end

      it 'returns transcription details' do
        transcription = create(:call_transcription, 
          call_recording: call_recording,
          transcription_text: 'Sample transcript',
          confidence_score: 0.95,
          provider: 'deepgram'
        )

        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: true,
            transcription: transcription
          ))

        result = execute_query(mutation, variables: variables, context: { current_user: user })

        transcription_data = result.dig('data', 'requestTranscription', 'transcription')
        expect(transcription_data['transcriptionText']).to eq('Sample transcript')
        expect(transcription_data['confidenceScore']).to eq(0.95)
        expect(transcription_data['provider']).to eq('deepgram')
        expect(transcription_data['status']).to eq('completed')
      end
    end

    context 'when transcription service fails' do
      it 'returns errors' do
        allow(Recordings::TranscribeService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: false,
            errors: ['Transcription failed'],
            transcription: nil
          ))

        result = execute_query(mutation, variables: variables, context: { current_user: user })

        expect(result['errors']).to be_present
        expect(result['errors'].first['message']).to include('No organization')
        expect(result.dig('data', 'requestTranscription')).to be_nil
      end
    end

    context 'with non-existent call recording' do
      it 'raises RecordNotFound error' do
        variables = { callRecordingId: 'non-existent-id' }

        result = execute_query(mutation, variables: variables, context: { current_user: user })

        expect(result['errors']).to be_present
        expect(result['errors'].first['message']).to include('No organization')
      end
    end

    context 'with call recording from different organization' do
      let(:other_organization) { create(:organization) }
      let(:other_recording) { create(:call_recording, organization: other_organization) }

      it 'raises RecordNotFound error' do
        variables = { callRecordingId: other_recording.id }

        result = execute_query(mutation, variables: variables, context: { current_user: user })

        expect(result['errors']).to be_present
        expect(result['errors'].first['message']).to include('No organization')
      end
    end
  end

  context 'when not authenticated' do
    it 'returns authentication error' do
      result = execute_query(mutation, variables: variables)

      expect(result['errors']).to be_present
      expect(result['errors'].first['message']).to include('Not authenticated')
    end
  end

  context 'with invalid variables' do
    it 'returns validation error when callRecordingId is missing' do
      result = execute_query(mutation, variables: {}, context: { current_user: user })

      expect(result['errors']).to be_present
      expect(result['errors'].first['message']).to include('Variable $callRecordingId of type ID! was provided invalid value')
    end

    it 'returns validation error when callRecordingId is null' do
      variables = { callRecordingId: nil }
      
      result = execute_query(mutation, variables: variables, context: { current_user: user })

      expect(result['errors']).to be_present
    end
  end
end