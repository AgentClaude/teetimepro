require "rails_helper"

RSpec.describe Marketplace::DisconnectService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let!(:connection) { create(:marketplace_connection, organization: organization, course: course) }

  describe ".call" do
    context "with valid connection" do
      it "destroys the connection" do
        result = described_class.call(
          organization: organization,
          connection_id: connection.id
        )

        expect(result).to be_success
        expect(MarketplaceConnection.find_by(id: connection.id)).to be_nil
      end

      it "cancels active listings" do
        listing = create(:marketplace_listing, marketplace_connection: connection, status: :listed)

        described_class.call(
          organization: organization,
          connection_id: connection.id
        )

        expect(MarketplaceListing.find_by(id: listing.id)).to be_nil # destroyed with connection
      end
    end

    context "with non-existent connection" do
      it "returns failure" do
        result = described_class.call(
          organization: organization,
          connection_id: 999999
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Marketplace connection not found")
      end
    end

    context "with connection from different org" do
      let(:other_org) { create(:organization) }

      it "returns not found" do
        result = described_class.call(
          organization: other_org,
          connection_id: connection.id
        )

        expect(result).not_to be_success
      end
    end
  end
end
