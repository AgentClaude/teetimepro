require "rails_helper"

RSpec.describe Accounting::ConnectService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "with valid QuickBooks params" do
      let(:oauth_params) do
        { code: "auth_code_123", state: "state_token", realmId: "realm_123" }
      end

      it "creates a new integration successfully" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: oauth_params
        )

        expect(result).to be_success
        expect(result.integration).to be_a(AccountingIntegration)
        expect(result.integration.provider).to eq("quickbooks")
        expect(result.integration).to be_persisted
      end

      it "marks the integration as connected" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: oauth_params
        )

        expect(result.integration.status).to eq("connected")
        expect(result.integration.connected_at).to be_present
      end

      it "stores company info" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: oauth_params
        )

        expect(result.integration.company_name).to be_present
      end

      it "updates existing integration instead of creating duplicate" do
        existing = AccountingIntegration.create!(
          organization: organization,
          provider: :quickbooks,
          status: :disconnected,
          account_mapping: {}
        )

        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: oauth_params
        )

        expect(result).to be_success
        expect(result.integration.id).to eq(existing.id)
        expect(AccountingIntegration.where(organization: organization, provider: :quickbooks).count).to eq(1)
      end
    end

    context "with valid Xero params" do
      let(:oauth_params) do
        { code: "xero_auth_code", state: "state_token" }
      end

      it "creates a Xero integration successfully" do
        result = described_class.call(
          organization: organization,
          provider: "xero",
          oauth_params: oauth_params
        )

        expect(result).to be_success
        expect(result.integration.provider).to eq("xero")
        expect(result.integration.status).to eq("connected")
      end
    end

    context "with invalid params" do
      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          provider: "quickbooks",
          oauth_params: { code: "test", state: "test", realmId: "test" }
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/organization/i))
      end

      it "fails when provider is invalid" do
        result = described_class.call(
          organization: organization,
          provider: "sage",
          oauth_params: { code: "test" }
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/provider/i))
      end

      it "fails when oauth_params is missing" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/oauth/i))
      end

      it "fails with missing QuickBooks OAuth parameters" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          oauth_params: { code: "test" }
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/QuickBooks OAuth/i))
      end

      it "fails with missing Xero OAuth parameters" do
        result = described_class.call(
          organization: organization,
          provider: "xero",
          oauth_params: { state: "test" }
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/Xero OAuth/i))
      end
    end
  end
end
