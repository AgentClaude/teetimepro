require "rails_helper"

RSpec.describe ApiKey, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
  end

  describe "validations" do
    subject { build(:api_key) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:key_digest) }
    it { should validate_uniqueness_of(:key_digest) }
    it { should validate_presence_of(:prefix) }
    it { should validate_length_of(:prefix).is_equal_to(8) }
  end

  describe "callbacks" do
    it "generates key_digest and prefix before creation" do
      organization = create(:organization)
      api_key = ApiKey.new(name: "Test Key", organization: organization)

      expect(api_key.key_digest).to be_nil

      api_key.save!

      expect(api_key.key_digest).to be_present
      expect(api_key.prefix).to be_present
      expect(api_key.prefix.length).to eq(8)
      expect(api_key.display_key).to start_with("tp_")
    end

    it "display_key is nil after reload" do
      api_key = create(:api_key)
      expect(api_key.display_key).to start_with("tp_")

      api_key.reload
      expect(api_key.display_key).to be_nil
    end
  end

  describe ".authenticate" do
    let(:organization) { create(:organization) }
    let!(:api_key) { create(:api_key, organization: organization, active: true) }

    context "with valid key" do
      it "returns the API key and updates last_used_at" do
        freeze_time do
          raw_key = api_key.display_key
          result = ApiKey.authenticate(raw_key)

          expect(result).to eq(api_key)
          expect(api_key.reload.last_used_at).to eq(Time.current)
        end
      end
    end

    context "with inactive API key" do
      let!(:inactive_key) { create(:api_key, :inactive, organization: organization) }

      it "returns nil" do
        raw_key = inactive_key.display_key
        result = ApiKey.authenticate(raw_key)
        expect(result).to be_nil
      end
    end

    context "with expired API key" do
      let!(:expired_key) { create(:api_key, :expired, organization: organization) }

      it "returns nil" do
        raw_key = expired_key.display_key
        result = ApiKey.authenticate(raw_key)
        expect(result).to be_nil
      end
    end

    context "with invalid key format" do
      it "returns nil for non-tp_ keys" do
        result = ApiKey.authenticate("invalid_key")
        expect(result).to be_nil
      end

      it "returns nil for nil key" do
        result = ApiKey.authenticate(nil)
        expect(result).to be_nil
      end
    end

    context "with non-existent key" do
      it "returns nil" do
        result = ApiKey.authenticate("tp_nonexistent_key_long_enough")
        expect(result).to be_nil
      end
    end
  end

  describe "#rate_limit" do
    it "returns correct limits for each tier" do
      standard_key = build(:api_key, rate_limit_tier: 'standard')
      premium_key = build(:api_key, rate_limit_tier: 'premium')
      enterprise_key = build(:api_key, rate_limit_tier: 'enterprise')

      expect(standard_key.rate_limit).to eq(60)
      expect(premium_key.rate_limit).to eq(300)
      expect(enterprise_key.rate_limit).to eq(1000)
    end
  end

  describe "#has_scope?" do
    let(:api_key) { build(:api_key, scopes: ['read', 'write']) }

    it "returns true for included scopes" do
      expect(api_key.has_scope?('read')).to be true
      expect(api_key.has_scope?(:write)).to be true
    end

    it "returns false for non-included scopes" do
      expect(api_key.has_scope?('admin')).to be false
    end
  end

  describe "#revoke!" do
    let(:api_key) { create(:api_key, active: true) }

    it "sets active to false" do
      api_key.revoke!
      expect(api_key.reload.active).to be false
    end
  end

  describe ".generate_unique_token" do
    it "generates a token with tp_ prefix" do
      token = ApiKey.generate_unique_token
      expect(token).to start_with("tp_")
      expect(token.length).to be > 10
    end

    it "generates unique tokens" do
      token1 = ApiKey.generate_unique_token
      token2 = ApiKey.generate_unique_token
      expect(token1).not_to eq(token2)
    end
  end
end
