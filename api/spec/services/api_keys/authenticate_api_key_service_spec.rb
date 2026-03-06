require 'rails_helper'

RSpec.describe ApiKeys::AuthenticateApiKeyService, type: :service do
  let(:organization) { create(:organization) }
  let!(:api_key) { create(:api_key, :with_write_access, organization: organization) }

  describe '#call' do
    context 'with valid parameters' do
      it 'authenticates successfully with a valid key' do
        raw_key = api_key.display_key
        
        result = described_class.call(key: raw_key)

        expect(result.success?).to be true
        expect(result.data[:api_key]).to eq(api_key)
        expect(result.data[:organization]).to eq(organization)
        expect(result.data[:rate_limit]).to eq(api_key.rate_limit)
        expect(result.data[:rate_limit_tier]).to eq(api_key.rate_limit_tier)
      end

      it 'authenticates without scope requirement' do
        raw_key = api_key.display_key
        
        result = described_class.call(key: raw_key)

        expect(result.success?).to be true
      end

      it 'authenticates with matching scope requirement' do
        raw_key = api_key.display_key
        
        result = described_class.call(key: raw_key, required_scope: 'read')

        expect(result.success?).to be true
      end

      it 'authenticates with write scope when key has write access' do
        raw_key = api_key.display_key
        
        result = described_class.call(key: raw_key, required_scope: 'write')

        expect(result.success?).to be true
      end
    end

    context 'with invalid key' do
      it 'fails when key is missing' do
        result = described_class.call(key: nil)

        expect(result.success?).to be false
        expect(result.error_messages).to include('API key is required')
      end

      it 'fails when key is blank' do
        result = described_class.call(key: '')

        expect(result.success?).to be false
        expect(result.error_messages).to include('API key is required')
      end

      it 'fails with invalid key format' do
        result = described_class.call(key: 'invalid_key')

        expect(result.success?).to be false
        expect(result.error_messages).to include('Invalid API key format')
      end

      it 'fails with short tp_ key' do
        result = described_class.call(key: 'tp_short')

        expect(result.success?).to be false
        expect(result.error_messages).to include('Invalid API key format')
      end

      it 'fails with non-existent key' do
        result = described_class.call(key: 'tp_nonexistent_key_that_is_long_enough')

        expect(result.success?).to be false
        expect(result.error_messages).to include('Invalid or inactive API key')
      end
    end

    context 'with inactive API key' do
      let!(:inactive_key) { create(:api_key, :inactive, organization: organization) }

      it 'fails to authenticate' do
        raw_key = inactive_key.display_key
        
        result = described_class.call(key: raw_key)

        expect(result.success?).to be false
        expect(result.error_messages).to include('Invalid or inactive API key')
      end
    end

    context 'with expired API key' do
      let!(:expired_key) { create(:api_key, :expired, organization: organization) }

      it 'fails to authenticate' do
        raw_key = expired_key.display_key
        
        result = described_class.call(key: raw_key)

        expect(result.success?).to be false
        expect(result.error_messages).to include('Invalid or inactive API key')
      end
    end

    context 'with scope requirements' do
      let!(:read_only_key) { create(:api_key, scopes: ['read'], organization: organization) }
      let!(:admin_key) { create(:api_key, :with_admin_access, organization: organization) }

      it 'succeeds when key has required scope' do
        raw_key = read_only_key.display_key
        
        result = described_class.call(key: raw_key, required_scope: 'read')

        expect(result.success?).to be true
      end

      it 'fails when key lacks required scope' do
        raw_key = read_only_key.display_key
        
        result = described_class.call(key: raw_key, required_scope: 'write')

        expect(result.success?).to be false
        expect(result.error_messages).to include('Insufficient permissions. Required scope: write')
      end

      it 'succeeds with admin scope for any requirement' do
        raw_key = admin_key.display_key
        
        result = described_class.call(key: raw_key, required_scope: 'admin')

        expect(result.success?).to be true
      end
    end
  end
end