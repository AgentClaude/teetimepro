require "rails_helper"

RSpec.describe Bookings::CheckAvailabilityService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) do
    create(:tee_time,
      tee_sheet: tee_sheet,
      starts_at: Date.tomorrow.beginning_of_day + 8.hours,
      price_cents: 7500
    )
  end

  describe ".call" do
    context "when tee time is available" do
      it "returns success with availability info" do
        result = described_class.call(tee_time: tee_time, players_count: 2)

        expect(result).to be_success
        expect(result.data.available).to be true
        expect(result.data.available_spots).to eq(4)
        expect(result.data.price_per_player).to eq(7500)
      end

      it "accepts up to max players" do
        result = described_class.call(tee_time: tee_time, players_count: 4)

        expect(result).to be_success
      end

      it "accepts a single player" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).to be_success
      end
    end

    context "when tee time is partially booked" do
      let(:tee_time) do
        create(:tee_time, :partially_booked,
          tee_sheet: tee_sheet,
          starts_at: Date.tomorrow.beginning_of_day + 8.hours
        )
      end

      it "allows booking remaining spots" do
        result = described_class.call(tee_time: tee_time, players_count: 2)

        expect(result).to be_success
        expect(result.data.available_spots).to eq(2)
      end

      it "rejects when requesting more than available" do
        result = described_class.call(tee_time: tee_time, players_count: 3)

        expect(result).to be_failure
        expect(result.errors.first).to include("spots available")
      end
    end

    context "when tee time is fully booked" do
      let(:tee_time) do
        create(:tee_time, :fully_booked,
          tee_sheet: tee_sheet,
          starts_at: Date.tomorrow.beginning_of_day + 8.hours
        )
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).to be_failure
        expect(result.errors).to include("This tee time is fully booked")
      end
    end

    context "when tee time is blocked" do
      let(:tee_time) do
        create(:tee_time, :blocked,
          tee_sheet: tee_sheet,
          starts_at: Date.tomorrow.beginning_of_day + 8.hours
        )
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).to be_failure
        expect(result.errors).to include("This tee time is blocked")
      end
    end

    context "when tee time is under maintenance" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: Date.tomorrow.beginning_of_day + 8.hours,
          status: :maintenance
        )
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).to be_failure
        expect(result.errors).to include("This tee time is under maintenance")
      end
    end

    context "when tee time is in the past" do
      let(:tee_time) do
        create(:tee_time, :past, tee_sheet: tee_sheet)
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).to be_failure
        expect(result.errors).to include("Cannot book tee times in the past")
      end
    end

    context "with missing parameters" do
      it "fails without tee_time" do
        result = described_class.call(tee_time: nil, players_count: 2)

        expect(result).to be_failure
      end

      it "fails without players_count" do
        result = described_class.call(tee_time: tee_time, players_count: nil)

        expect(result).to be_failure
      end
    end
  end
end
