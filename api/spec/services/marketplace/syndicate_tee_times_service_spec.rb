require "rails_helper"

RSpec.describe Marketplace::SyndicateTeeTimesService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:connection) { create(:marketplace_connection, organization: organization, course: course) }

  describe ".call" do
    context "with active connection and available tee times" do
      let(:tee_sheet) { create(:tee_sheet, course: course, date: 3.days.from_now.to_date) }
      let!(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: 3.days.from_now.beginning_of_day + 10.hours,
          status: :available,
          price_cents: 7500
        )
      end

      it "creates marketplace listings" do
        result = described_class.call(connection: connection)

        expect(result).to be_success
        expect(result.data[:created_count]).to eq(1)
        expect(MarketplaceListing.count).to eq(1)
      end

      it "doesn't duplicate existing listings" do
        described_class.call(connection: connection)
        result = described_class.call(connection: connection)

        expect(result).to be_success
        expect(result.data[:created_count]).to eq(0)
        expect(MarketplaceListing.count).to eq(1)
      end
    end

    context "with paused connection" do
      let(:paused_connection) { create(:marketplace_connection, :paused, organization: organization, course: course) }

      it "returns failure" do
        result = described_class.call(connection: paused_connection)

        expect(result).not_to be_success
        expect(result.errors).to include("Connection is not active")
      end
    end

    context "with discount settings" do
      let(:connection_with_discount) do
        create(:marketplace_connection,
          organization: organization,
          course: course,
          settings: { "discount_percent" => 10 }
        )
      end

      let(:tee_sheet) { create(:tee_sheet, course: course, date: 3.days.from_now.to_date) }
      let!(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: 3.days.from_now.beginning_of_day + 10.hours,
          price_cents: 10000
        )
      end

      it "applies discount to listed price" do
        result = described_class.call(connection: connection_with_discount)

        listing = result.data[:listings].first
        expect(listing.listed_price_cents).to eq(9000)
      end
    end

    context "with tee times too close to start" do
      let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
      let!(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: 1.hour.from_now, # Within min_advance_hours
          status: :available
        )
      end

      it "excludes tee times within minimum advance window" do
        result = described_class.call(connection: connection)

        expect(result).to be_success
        expect(result.data[:created_count]).to eq(0)
      end
    end
  end
end
