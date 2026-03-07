require "rails_helper"

RSpec.describe Accounting::ConfigureMappingService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "with valid params" do
      let!(:integration) do
        AccountingIntegration.create!(
          organization: organization,
          provider: :quickbooks,
          status: :connected,
          access_token: "test_token",
          refresh_token: "test_refresh",
          account_mapping: {}
        )
      end

      it "updates the account mapping successfully" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "green_fees",
          account_id: "100",
          account_name: "Green Fees Revenue"
        )

        expect(result).to be_success
        expect(result.integration).to eq(integration)
        expect(result.integration.account_mapping["green_fees"]).to eq(
          "account_id" => "100",
          "account_name" => "Green Fees Revenue"
        )
      end

      it "preserves existing mappings when adding a new one" do
        integration.update!(account_mapping: {
          "green_fees" => { "account_id" => "100", "account_name" => "Green Fees" }
        })

        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "cart_fees",
          account_id: "200",
          account_name: "Cart Rental Income"
        )

        expect(result).to be_success
        expect(result.integration.account_mapping.keys).to contain_exactly("green_fees", "cart_fees")
      end

      it "overwrites existing mapping for the same category" do
        integration.update!(account_mapping: {
          "green_fees" => { "account_id" => "100", "account_name" => "Old Name" }
        })

        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "green_fees",
          account_id: "999",
          account_name: "New Name"
        )

        expect(result).to be_success
        expect(result.integration.account_mapping["green_fees"]["account_id"]).to eq("999")
        expect(result.integration.account_mapping["green_fees"]["account_name"]).to eq("New Name")
      end
    end

    context "with invalid params" do
      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          provider: "quickbooks",
          category: "green_fees",
          account_id: "100",
          account_name: "Revenue"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/organization/i))
      end

      it "fails when provider is invalid" do
        result = described_class.call(
          organization: organization,
          provider: "sage",
          category: "green_fees",
          account_id: "100",
          account_name: "Revenue"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/provider/i))
      end

      it "fails when category is invalid" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "invalid_category",
          account_id: "100",
          account_name: "Revenue"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/category/i))
      end

      it "fails when account_id is missing" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "green_fees",
          account_id: nil,
          account_name: "Revenue"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/account/i))
      end

      it "fails when account_name is missing" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "green_fees",
          account_id: "100",
          account_name: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/account name/i))
      end
    end

    context "when integration does not exist" do
      it "returns failure" do
        result = described_class.call(
          organization: organization,
          provider: "quickbooks",
          category: "green_fees",
          account_id: "100",
          account_name: "Revenue"
        )

        expect(result).to be_failure
        expect(result.errors).to include(match(/not found/i))
      end
    end

    context "with all valid categories" do
      let!(:integration) do
        AccountingIntegration.create!(
          organization: organization,
          provider: :xero,
          status: :connected,
          access_token: "test_token",
          refresh_token: "test_refresh",
          account_mapping: {}
        )
      end

      %w[green_fees cart_fees merchandise food_beverage lessons tournaments bank_deposits].each do |category|
        it "accepts #{category} as a valid category" do
          result = described_class.call(
            organization: organization,
            provider: "xero",
            category: category,
            account_id: "100",
            account_name: "Test Account"
          )

          expect(result).to be_success
        end
      end
    end
  end
end
