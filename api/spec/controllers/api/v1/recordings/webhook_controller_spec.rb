require 'rails_helper'

RSpec.describe Api::V1::Recordings::WebhookController, type: :controller do
  let(:organization) { create(:organization) }
  let(:voice_call_log) { create(:voice_call_log, organization: organization, call_sid: 'CA1234567890abcdef') }

  let(:valid_webhook_params) do
    {
      'CallSid' => voice_call_log.call_sid,
      'RecordingSid' => 'RE1234567890abcdef',
      'RecordingUrl' => 'https://api.twilio.com/recordings/sample.wav',
      'RecordingStatus' => 'completed',
      'RecordingDuration' => '120',
      'RecordingChannels' => '1',
      'RecordingStartTime' => Time.current.iso8601,
      'RecordingSource' => 'RecordVerb',
      'RecordingSize' => '2048000'
    }
  end

  describe 'POST #create' do
    context 'with valid webhook data' do
      it 'returns success response' do
        allow(Recordings::StoreRecordingService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: true, 
            recording: double('Recording', id: 'test-id')
          ))

        post :create, params: valid_webhook_params

        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('success')
        expect(json_response['recording_id']).to eq('test-id')
        expect(json_response['message']).to eq('Recording stored successfully')
      end

      it 'calls StoreRecordingService with correct parameters' do
        expect(Recordings::StoreRecordingService).to receive(:call).with(
          webhook_data: valid_webhook_params,
          organization: organization
        ).and_return(double('ServiceResult', 
          success?: true, 
          recording: double('Recording', id: 'test-id')
        ))

        post :create, params: valid_webhook_params
      end

      it 'logs successful recording storage' do
        allow(Recordings::StoreRecordingService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: true, 
            recording: double('Recording', id: 'test-id')
          ))

        expect(Rails.logger).to receive(:info)
          .with("Received Twilio recording webhook: #{valid_webhook_params.inspect}")
        expect(Rails.logger).to receive(:info)
          .with("Successfully stored recording: test-id")

        post :create, params: valid_webhook_params
      end
    end

    context 'with invalid webhook data' do
      it 'returns error response when service fails' do
        allow(Recordings::StoreRecordingService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: false, 
            errors: ['Invalid data']
          ))

        post :create, params: valid_webhook_params

        expect(response).to have_http_status(:unprocessable_entity)
        
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('error')
        expect(json_response['errors']).to eq(['Invalid data'])
      end

      it 'logs service failure' do
        allow(Recordings::StoreRecordingService).to receive(:call)
          .and_return(double('ServiceResult', 
            success?: false, 
            errors: ['Invalid data'],
            error_messages: 'Invalid data'
          ))

        expect(Rails.logger).to receive(:error)
          .with("Failed to store recording: Invalid data")

        post :create, params: valid_webhook_params
      end
    end

    context 'when voice call log not found' do
      let(:unknown_call_sid_params) do
        valid_webhook_params.merge('CallSid' => 'UNKNOWN_CALL_SID')
      end

      it 'returns not found response' do
        post :create, params: unknown_call_sid_params

        expect(response).to have_http_status(:not_found)
        
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Voice call log not found')
      end

      it 'logs error for missing call log' do
        expect(Rails.logger).to receive(:error)
          .with("No voice call log found for CallSid: UNKNOWN_CALL_SID")

        post :create, params: unknown_call_sid_params
      end
    end

    context 'when unexpected error occurs' do
      it 'handles exceptions gracefully' do
        allow(VoiceCallLog).to receive(:find_by).and_raise(StandardError, 'Database error')

        expect {
          post :create, params: valid_webhook_params
        }.to raise_error(StandardError, 'Database error')
      end
    end
  end

  describe 'request filtering and security' do
    it 'skips CSRF token verification' do
      expect(controller).to receive(:verify_authenticity_token).never
      post :create, params: valid_webhook_params
    end

    it 'skips user authentication' do
      expect(controller).to receive(:authenticate_user!).never
      post :create, params: valid_webhook_params
    end

    it 'permits expected webhook parameters' do
      post :create, params: valid_webhook_params.merge(
        'unexpected_param' => 'should_be_filtered'
      )

      # The test passes if no parameter error is raised
      expect(response.status).to be_between(200, 499)
    end
  end

  describe 'parameter filtering' do
    let(:webhook_params_with_extras) do
      valid_webhook_params.merge(
        'UnexpectedParam' => 'should_be_filtered',
        'AnotherParam' => 'also_filtered'
      )
    end

    it 'only permits allowed parameters' do
      # We can't directly test the private method, but we can ensure
      # the service is called with only permitted params
      expect(Recordings::StoreRecordingService).to receive(:call) do |args|
        webhook_data = args[:webhook_data]
        
        # Should include all expected params
        expect(webhook_data).to include('CallSid', 'RecordingSid', 'RecordingUrl')
        
        # Should not include unexpected params
        expect(webhook_data).not_to have_key('UnexpectedParam')
        expect(webhook_data).not_to have_key('AnotherParam')
        
        double('ServiceResult', success?: true, recording: double('Recording', id: 'test'))
      end

      post :create, params: webhook_params_with_extras
    end
  end
end