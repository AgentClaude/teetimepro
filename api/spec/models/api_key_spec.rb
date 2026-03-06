require "rails_helper"

RSpec.describe ApiKey, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:token) }
  end

  describe "scopes" do
    let(:organization) { create(:organization) }
    let!(:active_key) { create(:api_key, organization: organization, active: true) }
    let!(:inactive_key) { create(:api_key, organization: organization, active: false) }

    describe ".active" do
      it "returns only active API keys" do
        expect(ApiKey.active).to contain_exactly(active_key)
      end
    end
  end

  describe "callbacks" do
    it "generates a token before creation" do
      organization = create(:organization)
      api_key = ApiKey.new(name: "Test Key", organization: organization)
      
      expect(api_key.token).to be_nil
      api_key.save!
      expect(api_key.token).to be_present
      expect(api_key.token).to start_with("tp_")
    end
  end

  describe ".authenticate" do
    let(:organization) { create(:organization) }
    let!(:api_key) { create(:api_key, organization: organization, active: true) }
    let!(:inactive_key) { create(:api_key, organization: organization, active: false) }

    context "with valid token" do
      it "returns the API key and updates last_used_at" do
        freeze_time do
          result = ApiKey.authenticate(api_key.token)
          
          expect(result).to eq(api_key)
          expect(api_key.reload.last_used_at).to eq(Time.current)
        end
      end
    end

    context "with inactive API key token" do
      it "returns nil" do
        result = ApiKey.authenticate(inactive_key.token)
        expect(result).to be_nil
      end
    end

    context "with non-existent token" do
      it "returns nil" do
        result = ApiKey.authenticate("tp_nonexistent")
        expect(result).to be_nil
      end
    end
  end

  describe "#revoke!" do
    let(:api_key) { create(:api_key, active: true) }

    it "sets active to false" do
      api_key.revoke!
      expect(api_key.reload.active?).to be_falsey
    end
  end

  describe ".generate_secure_token" do
    it "generates a token with tp_ prefix" do
      token = ApiKey.generate_secure_token
      expect(token).to start_with("tp_")
      expect(token.length).to be > 10
    end

    it "generates unique tokens" do
      token1 = ApiKey.generate_secure_token
      token2 = ApiKey.generate_secure_token
      expect(token1).not_to eq(token2)
    end
  end
end