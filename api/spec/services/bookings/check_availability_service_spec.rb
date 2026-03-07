require "rails_helper"

RSpec.describe Bookings::CheckAvailabilityService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current + 1.day) }
  let(:tomorrow) { Date.current + 1.day }

  describe ".call" do
    context "with an available slot" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 1,
          price_cents: 5000,
          status: :partially_booked)
      end

      it "returns success with availability info" do
        result = described_class.call(tee_time: tee_time, players_count: 2)

        expect(result).to be_success
        expect(result.data[:available]).to be true
        expect(result.data[:available_spots]).to eq(3)
        expect(result.data[:price_per_player]).to eq(5000)
      end
    end

    context "with a fully booked slot" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 4,
          status: :fully_booked)
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).not_to be_success
        expect(result.errors).to include("This tee time is fully booked")
      end
    end

    context "with insufficient spots" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 3,
          status: :partially_booked)
      end

      it "returns failure when requesting more spots than available" do
        result = described_class.call(tee_time: tee_time, players_count: 2)

        expect(result).not_to be_success
        expect(result.errors.first).to include("Only 1 spots available")
      end
    end

    context "with a blocked slot" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :blocked)
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).not_to be_success
        expect(result.errors).to include("This tee time is blocked")
      end
    end

    context "with a maintenance slot" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :maintenance)
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).not_to be_success
        expect(result.errors).to include("This tee time is under maintenance")
      end
    end

    context "with a past tee time" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: create(:tee_sheet, course: course, date: Date.current),
          starts_at: 2.hours.ago,
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "returns failure" do
        result = described_class.call(tee_time: tee_time, players_count: 1)

        expect(result).not_to be_success
        expect(result.errors).to include("Cannot book tee times in the past")
      end
    end

    context "with missing params" do
      it "fails when tee_time is nil" do
        result = described_class.call(tee_time: nil, players_count: 1)
        expect(result).not_to be_success
      end

      it "fails when players_count is nil" do
        tee_time = create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)

        result = described_class.call(tee_time: tee_time, players_count: nil)
        expect(result).not_to be_success
      end
    end
  end
end
