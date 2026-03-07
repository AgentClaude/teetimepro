require 'rails_helper'

RSpec.describe Voice::InitiateHandoffService, type: :service do
  let(:organization) { create(:organization) }
  let(:voice_call_log) { create(:voice_call_log, organization: organization) }
  
  let(:valid_params) do
    {
      organization: organization,
      call_sid: "CA1234567890abcdef",
      caller_phone: "+15551234567",
      caller_name: "John Doe",
      reason: "billing_inquiry",
      reason_detail: "Customer wants to dispute a charge",
      voice_call_log_id: voice_call_log.id
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      it 'creates a new voice handoff successfully' do
        expect {
          result = described_class.call(valid_params)
          expect(result.success?).to be true
        }.to change { VoiceHandoff.count }.by(1)
      end

      it 'returns the created handoff and transfer information' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.handoff).to be_a(VoiceHandoff)
        expect(result.handoff.call_sid).to eq(valid_params[:call_sid])
        expect(result.handoff.caller_phone).to eq("+15551234567") # normalized
        expect(result.handoff.reason).to eq("billing_inquiry")
        expect(result.handoff.organization).to eq(organization)
        expect(result.handoff.voice_call_log).to eq(voice_call_log)
        expect(result.transfer_number).to be_present
        expect(result.created).to be true
      end

      it 'sets default transfer number from environment' do
        allow(ENV).to receive(:fetch).with('HANDOFF_PHONE_NUMBER', '+1234567890').and_return('+15559876543')
        
        result = described_class.call(valid_params)
        
        expect(result.transfer_number).to eq('+15559876543')
        expect(result.handoff.transfer_to).to eq('+15559876543')
      end

      it 'uses organization voice_config handoff number if available' do
        organization.update!(voice_config: { 'handoff_phone_number' => '+15554445555' })
        
        result = described_class.call(valid_params)
        
        expect(result.transfer_number).to eq('+15554445555')
        expect(result.handoff.transfer_to).to eq('+15554445555')
      end

      it 'normalizes US phone numbers' do
        params = valid_params.merge(caller_phone: "5551234567") # no +1
        
        result = described_class.call(params)
        
        expect(result.handoff.caller_phone).to eq("+15551234567")
      end

      it 'handles 11-digit US numbers' do
        params = valid_params.merge(caller_phone: "15551234567") # no +
        
        result = described_class.call(params)
        
        expect(result.handoff.caller_phone).to eq("+15551234567")
      end

      it 'leaves international numbers unchanged' do
        params = valid_params.merge(caller_phone: "+441234567890")
        
        result = described_class.call(params)
        
        expect(result.handoff.caller_phone).to eq("+441234567890")
      end

      it 'works without voice_call_log_id' do
        params = valid_params.except(:voice_call_log_id)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.handoff.voice_call_log).to be_nil
      end

      it 'works without caller_name' do
        params = valid_params.except(:caller_name)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.handoff.caller_name).to be_nil
      end

      it 'works without reason_detail' do
        params = valid_params.except(:reason_detail)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.handoff.reason_detail).to be_nil
      end
    end

    context 'when handoff already exists for call_sid' do
      let!(:existing_handoff) { create(:voice_handoff, call_sid: valid_params[:call_sid], organization: organization) }

      it 'does not create a new handoff' do
        expect {
          result = described_class.call(valid_params)
          expect(result.success?).to be true
        }.not_to change { VoiceHandoff.count }
      end

      it 'returns the existing handoff' do
        result = described_class.call(valid_params)

        expect(result.success?).to be true
        expect(result.handoff).to eq(existing_handoff)
        expect(result.already_exists).to be true
      end
    end

    context 'with invalid parameters' do
      it 'fails when organization is missing' do
        params = valid_params.except(:organization)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Organization can't be blank")
      end

      it 'fails when call_sid is missing' do
        params = valid_params.except(:call_sid)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Call sid can't be blank")
      end

      it 'fails when caller_phone is missing' do
        params = valid_params.except(:caller_phone)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Caller phone can't be blank")
      end

      it 'fails when reason is missing' do
        params = valid_params.except(:reason)
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Reason can't be blank")
      end

      it 'fails when reason is invalid' do
        params = valid_params.merge(reason: "invalid_reason")
        
        result = described_class.call(params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Reason is not included in the list")
      end
    end

    context 'when voice_call_log_id is invalid' do
      it 'ignores invalid voice_call_log_id' do
        params = valid_params.merge(voice_call_log_id: 99999)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.handoff.voice_call_log).to be_nil
      end

      it 'ignores voice_call_log from different organization' do
        other_org = create(:organization)
        other_call_log = create(:voice_call_log, organization: other_org)
        params = valid_params.merge(voice_call_log_id: other_call_log.id)
        
        result = described_class.call(params)
        
        expect(result.success?).to be true
        expect(result.handoff.voice_call_log).to be_nil
      end
    end

    context 'when database error occurs' do
      it 'handles transaction rollback gracefully' do
        allow(VoiceHandoff).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end

      it 'handles standard errors gracefully' do
        allow(VoiceHandoff).to receive(:create!).and_raise(StandardError.new("Database connection failed"))
        
        result = described_class.call(valid_params)
        
        expect(result.failure?).to be true
        expect(result.errors).to include("Failed to create handoff: Database connection failed")
      end
    end
  end
end