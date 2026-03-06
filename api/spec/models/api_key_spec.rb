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
    it { should validate_presence_of(:scopes) }
    it { should validate_presence_of(:rate_limit_tier) }
    it { should validate_inclusion_of(:rate_limit_tier).in_array(%w[standard premium enterprise]) }
  end

  describe "scopes" do
    let(:organization) { create(:organization) }
    let!(:active_key) { create(:api_key, organization: organization, active: true) }
    let!(:inactive_key) { create(:api_key, organization: organization, active: false) }
    let!(:expired_key) { create(:api_key, :expired, organization: organization, active: true) }

    describe ".active" do
      it "returns only active and non-expired API keys" do
        expect(ApiKey.active).to contain_exactly(active_key)
      end
    end
  end

  describe "callbacks" do
    it "generates key digest and prefix before creation" do
      organization = create(:organization)
      api_key = ApiKey.new(name: "Test Key", organization: organization)
      
      expect(api_key.key_digest).to be_nil
      expect(api_key.prefix).to be_nil
      
      api_key.save!
      
      expect(api_key.key_digest).to be_present
      expect(api_key.prefix).to be_present
      expect(api_key.prefix.length).to eq(8)
      expect(api_key.display_key).to start_with("tp_")
    end

    it "sets default scopes when blank" do
      api_key = create(:api_key, scopes: [])
      expect(api_key.reload.scopes).to eq(['read'])
    end
  end

  describe ".authenticate" do
    let(:organization) { create(:organization) }
    let!(:api_key) { create(:api_key, organization: organization, active: true) }
    let!(:inactive_key) { create(:api_key, :inactive, organization: organization) }
    let!(:expired_key) { create(:api_key, :expired, organization: organization, active: true) }

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
      it "returns nil" do
        raw_key = inactive_key.display_key
        result = ApiKey.authenticate(raw_key)
        expect(result).to be_nil
      end
    end

    context "with expired API key" do
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
        result = ApiKey.authenticate("tp_nonexistent")
        expect(result).to be_nil
      end
    end
  end

  describe "#rate_limit" do
    it "returns correct limits for each tier" do
      standard_key = create(:api_key, rate_limit_tier: 'standard')
      premium_key = create(:api_key, rate_limit_tier: 'premium')
      enterprise_key = create(:api_key, rate_limit_tier: 'enterprise')

      expect(standard_key.rate_limit).to eq(60)
      expect(premium_key.rate_limit).to eq(300)
      expect(enterprise_key.rate_limit).to eq(1000)
    end
  end

  describe "#has_scope?" do
    let(:api_key) { create(:api_key, scopes: ['read', 'write']) }

    it "returns true for included scopes" do
      expect(api_key.has_scope?('read')).to be true
      expect(api_key.has_scope?(:write)).to be true
    end

    it "returns false for non-included scopes" do
      expect(api_key.has_scope?('admin')).to be false
      expect(api_key.has_scope?(:admin)).to be false
    end
  end

  describe "#revoke!" do
    let(:api_key) { create(:api_key, active: true) }

    it "sets active to false" do
      api_key.revoke!
      expect(api_key.reload.active?).to be_falsey
    end
  end

  describe "#expires_soon?" do
    it "returns true when expires within 7 days" do
      api_key = create(:api_key, expires_at: 3.days.from_now)
      expect(api_key.expires_soon?).to be true
    end

    it "returns false when expires after 7 days" do
      api_key = create(:api_key, expires_at: 10.days.from_now)
      expect(api_key.expires_soon?).to be false
    end

    it "returns false when never expires" do
      api_key = create(:api_key, expires_at: nil)
      expect(api_key.expires_soon?).to be false
    end
  end

  describe "#expired?" do
    it "returns true when expired" do
      api_key = create(:api_key, expires_at: 1.day.ago)
      expect(api_key.expired?).to be true
    end

    it "returns false when not expired" do
      api_key = create(:api_key, expires_at: 1.day.from_now)
      expect(api_key.expired?).to be false
    end

    it "returns false when never expires" do
      api_key = create(:api_key, expires_at: nil)
      expect(api_key.expired?).to be false
    end
  end

  describe "#display_key" do
    it "returns the raw key only immediately after creation" do
      api_key = build(:api_key)
      expect(api_key.display_key).to be_nil
      
      api_key.save!
      expect(api_key.display_key).to start_with("tp_")
      
      # After reload, raw key is no longer available
      api_key.reload
      expect(api_key.display_key).to be_nil
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