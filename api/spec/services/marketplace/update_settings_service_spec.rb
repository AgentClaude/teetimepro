require "rails_helper"

RSpec.describe Marketplace::UpdateSettingsService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let!(:connection) { create(:marketplace_connection, organization: organization, course: course) }

  describe ".call" do
    context "updating settings" do
      it "merges new settings with existing" do
        result = described_class.call(
          organization: organization,
          connection_id: connection.id,
          settings: { "discount_percent" => 15, "min_advance_hours" => 6 }
        )

        expect(result).to be_success
        conn = result.data[:connection]
        expect(conn.settings["discount_percent"]).to eq(15)
        expect(conn.settings["min_advance_hours"]).to eq(6)
      end

      it "strips unknown settings" do
        result = described_class.call(
          organization: organization,
          connection_id: connection.id,
          settings: { "discount_percent" => 10, "evil_setting" => true }
        )

        expect(result).to be_success
        expect(result.data[:connection].settings).not_to have_key("evil_setting")
      end
    end

    context "updating status" do
      it "allows pausing a connection" do
        result = described_class.call(
          organization: organization,
          connection_id: connection.id,
          status: "paused"
        )

        expect(result).to be_success
        expect(result.data[:connection].status).to eq("paused")
      end

      it "rejects invalid status" do
        result = described_class.call(
          organization: organization,
          connection_id: connection.id,
          status: "deleted"
        )

        expect(result).not_to be_success
      end
    end

    context "with missing connection" do
      it "returns failure" do
        result = described_class.call(
          organization: organization,
          connection_id: 999999,
          settings: { "discount_percent" => 10 }
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Marketplace connection not found")
      end
    end
  end
end
