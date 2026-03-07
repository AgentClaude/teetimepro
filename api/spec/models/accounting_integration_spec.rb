require "rails_helper"

RSpec.describe AccountingIntegration, type: :model do
  let(:organization) { create(:organization) }

  subject(:integration) do
    described_class.new(
      organization: organization,
      provider: :quickbooks,
      account_mapping: {}
    )
  end

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:accounting_syncs).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:organization) }

    it "validates uniqueness of provider scoped to organization" do
      described_class.create!(
        organization: organization,
        provider: :quickbooks,
        account_mapping: {}
      )

      duplicate = described_class.new(
        organization: organization,
        provider: :quickbooks,
        account_mapping: {}
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:provider]).to be_present
    end

    it "allows different providers for same organization" do
      described_class.create!(
        organization: organization,
        provider: :quickbooks,
        account_mapping: {}
      )

      xero = described_class.new(
        organization: organization,
        provider: :xero,
        account_mapping: {}
      )

      expect(xero).to be_valid
    end
  end

  describe "scopes" do
    describe ".active" do
      it "returns only connected integrations" do
        connected = described_class.create!(
          organization: organization,
          provider: :quickbooks,
          status: :connected,
          account_mapping: {}
        )
        described_class.create!(
          organization: create(:organization),
          provider: :xero,
          status: :disconnected,
          account_mapping: {}
        )

        expect(described_class.active).to contain_exactly(connected)
      end
    end

    describe ".for_organization" do
      it "returns integrations for the given organization" do
        mine = described_class.create!(
          organization: organization,
          provider: :quickbooks,
          account_mapping: {}
        )
        described_class.create!(
          organization: create(:organization),
          provider: :xero,
          account_mapping: {}
        )

        expect(described_class.for_organization(organization)).to contain_exactly(mine)
      end
    end
  end

  describe "#connected?" do
    it "returns true when connected with access token" do
      integration.status = :connected
      integration.access_token = "token"

      expect(integration.connected?).to be true
    end

    it "returns false when disconnected" do
      integration.status = :disconnected

      expect(integration.connected?).to be false
    end

    it "returns false when connected but no access token" do
      integration.status = :connected
      integration.access_token = nil

      expect(integration.connected?).to be false
    end
  end

  describe "#tokens_expired?" do
    it "returns true when connected_at is blank" do
      integration.connected_at = nil

      expect(integration.tokens_expired?).to be true
    end

    it "returns true when connected over 1 hour ago" do
      integration.connected_at = 2.hours.ago

      expect(integration.tokens_expired?).to be true
    end

    it "returns false when connected within the last hour" do
      integration.connected_at = 30.minutes.ago

      expect(integration.tokens_expired?).to be false
    end
  end

  describe "#mark_connected!" do
    before { integration.save! }

    it "updates status and company info" do
      integration.mark_connected!(company_name: "Test Club", country_code: "US")

      expect(integration.status).to eq("connected")
      expect(integration.company_name).to eq("Test Club")
      expect(integration.country_code).to eq("US")
      expect(integration.connected_at).to be_present
      expect(integration.last_error_message).to be_nil
    end
  end

  describe "#mark_disconnected!" do
    before do
      integration.update!(
        status: :connected,
        access_token: "token",
        refresh_token: "refresh",
        connected_at: Time.current
      )
    end

    it "clears all connection data" do
      integration.mark_disconnected!

      expect(integration.status).to eq("disconnected")
      expect(integration.access_token).to be_nil
      expect(integration.refresh_token).to be_nil
      expect(integration.realm_id).to be_nil
      expect(integration.connected_at).to be_nil
    end
  end

  describe "#mark_error!" do
    before { integration.save! }

    it "sets error status and message" do
      integration.mark_error!("Token expired")

      expect(integration.status).to eq("error")
      expect(integration.last_error_message).to eq("Token expired")
      expect(integration.last_error_at).to be_present
    end
  end

  describe "#set_account_mapping" do
    before { integration.save! }

    it "sets a new mapping" do
      integration.set_account_mapping("green_fees", "100", "Green Fees Revenue")

      expect(integration.account_mapping["green_fees"]).to eq(
        "account_id" => "100",
        "account_name" => "Green Fees Revenue"
      )
    end

    it "preserves existing mappings" do
      integration.update!(account_mapping: {
        "cart_fees" => { "account_id" => "200", "account_name" => "Cart Fees" }
      })

      integration.set_account_mapping("green_fees", "100", "Green Fees")

      expect(integration.account_mapping.keys).to contain_exactly("cart_fees", "green_fees")
    end
  end

  describe "#account_for" do
    before do
      integration.update!(account_mapping: {
        "green_fees" => { "account_id" => "100", "account_name" => "Green Fees" }
      })
    end

    it "returns the account_id for a mapped category" do
      expect(integration.account_for(:green_fees)).to eq("100")
    end

    it "returns nil for unmapped category" do
      expect(integration.account_for(:cart_fees)).to be_nil
    end
  end

  describe "#company_id" do
    it "returns realm_id for quickbooks" do
      integration.provider = :quickbooks
      integration.realm_id = "realm_123"

      expect(integration.company_id).to eq("realm_123")
    end

    it "returns tenant_id for xero" do
      integration.provider = :xero
      integration.tenant_id = "tenant_456"

      expect(integration.company_id).to eq("tenant_456")
    end
  end
end
