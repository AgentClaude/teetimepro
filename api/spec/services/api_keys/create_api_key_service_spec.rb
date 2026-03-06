require 'rails_helper'

RSpec.describe ApiKeys::CreateApiKeyService, type: :service do
  let(:organization) { create(:organization) }

  describe '#call' do
    context 'with valid parameters' do
      let(:params) do
        {
          organization: organization,
          name: 'Test API Key',
          scopes: ['read', 'write'],
          rate_limit_tier: 'premium',
          expires_at: 1.year.from_now
        }
      end

      it 'creates an API key successfully' do
        expect {
          result = described_class.call(params)
          expect(result.success?).to be true
        }.to change(ApiKey, :count).by(1)
      end

      it 'returns the API key data with raw key' do
        result = described_class.call(params)

        expect(result.success?).to be true
        data = result.data[:api_key]
        
        expect(data[:id]).to be_present
        expect(data[:name]).to eq('Test API Key')
        expect(data[:key]).to start_with('tp_')
        expect(data[:prefix]).to eq(data[:key][0..7])
        expect(data[:scopes]).to eq(['read', 'write'])
        expect(data[:rate_limit_tier]).to eq('premium')
        expect(data[:rate_limit]).to eq(300)
        expect(data[:expires_at]).to be_present
        expect(data[:created_at]).to be_present
      end

      it 'normalizes scopes correctly' do
        result = described_class.call(
          organization: organization,
          name: 'Test API Key',
          scopes: ['read', 'invalid_scope', 'write', 'admin', 'another_invalid']
        )

        expect(result.success?).to be true
        expect(result.data[:api_key][:scopes]).to eq(['read', 'write', 'admin'])
      end

      it 'sets default scopes when empty' do
        result = described_class.call(
          organization: organization,
          name: 'Test API Key',
          scopes: []
        )

        expect(result.success?).to be true
        expect(result.data[:api_key][:scopes]).to eq(['read'])
      end

      it 'sets default rate_limit_tier when not specified' do
        result = described_class.call(
          organization: organization,
          name: 'Test API Key'
        )

        expect(result.success?).to be true
        expect(result.data[:api_key][:rate_limit_tier]).to eq('standard')
        expect(result.data[:api_key][:rate_limit]).to eq(60)
      end
    end

    context 'with invalid parameters' do
      it 'fails when organization is missing' do
        result = described_class.call(
          organization: nil,
          name: 'Test API Key'
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include("Organization can't be blank")
      end

      it 'fails when name is missing' do
        result = described_class.call(
          organization: organization,
          name: ''
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include("Name can't be blank")
      end

      it 'fails when name is too short' do
        result = described_class.call(
          organization: organization,
          name: 'ab'
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include("Name is too short (minimum is 3 characters)")
      end

      it 'fails when name is too long' do
        result = described_class.call(
          organization: organization,
          name: 'a' * 101
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include("Name is too long (maximum is 100 characters)")
      end

      it 'fails when rate_limit_tier is invalid' do
        result = described_class.call(
          organization: organization,
          name: 'Test API Key',
          rate_limit_tier: 'invalid_tier'
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include("Rate limit tier is not included in the list")
      end
    end

    context 'when API key creation fails' do
      before do
        allow_any_instance_of(ApiKey).to receive(:save).and_return(false)
        allow_any_instance_of(ApiKey).to receive(:errors).and_return(
          double('errors', full_messages: ['Database error'])
        )
      end

      it 'returns failure with error messages' do
        result = described_class.call(
          organization: organization,
          name: 'Test API Key'
        )

        expect(result.success?).to be false
        expect(result.error_messages).to include('Database error')
      end
    end
  end
end