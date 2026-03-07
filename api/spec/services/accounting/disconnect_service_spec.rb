require "rails_helper"

RSpec.describe Accounting::DisconnectService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "when integration exists and is connected" do
      let!(:integration) do
        AccountingIntegration.create!(
          organization: organization,
          provider: :quickbooks,
          status: :connected,
          access_token: "test_token",
          refresh_token: "test_refresh",
          realm_id: "realm_123",
          connected_at: 1.day.ago,
          account_mapping: {}
        )
      end

      it "disconnects the integration successfully" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks"
        )

        expect(result).to be_success
        expect(result.message).to match(/disconnected/i)
      end

      it "clears tokens and marks as disconnected" do
        described_class.call(
          organization: organization,
          provider: "quickbooks"
        )

        integration.reload
        expect(integration.status).to eq("disconnected")
        expect(integration.access_token).to be_nil
        expect(integration.refresh_token).to be_nil
        expect(integration.connected_at).to be_nil
      end

      it "marks pending syncs as failed" do
        sync = AccountingSync.create!(
          accounting_integration: integration,
          sync_type: "invoice",
          status: :pending,
          syncable: create(:booking, organization: organization)
        )

        described_class.call(
          organization: organization,
          provider: "quickbooks"
        )

        sync.reload
        expect(sync.status).to eq("failed")
        expect(sync.error_message).to match(/disconnected/i)
      end
    end

    context "when integration does not exist" do
      it "returns success with appropriate message" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks"
        )

        expect(result).to be_success
        expect(result.message).to match(/no integration found/i)
      end
    end

    context "when integration is already disconnected" do
      let!(:integration) do
        AccountingIntegration.create!(
          organization: organization,
          provider: :xero,
          status: :disconnected,
          account_mapping: {}
        )
      end

      it "completes without error" do
        result = described_class.call(
          organization: organization,
          provider: "xero"
        )

        expect(result).to be_success
      end
    end

    context "with invalid params" do
      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          provider: "quickbooks"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/organization/i))
      end

      it "fails when provider is invalid" do
        result = described_class.call(
          organization: organization,
          provider: "sage"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/provider/i))
      end
    end
  end
end
