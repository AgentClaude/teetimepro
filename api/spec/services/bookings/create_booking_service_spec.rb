require "rails_helper"

RSpec.describe Bookings::CreateBookingService do
  let(:organization) { create(:organization, :with_stripe) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Date.tomorrow.beginning_of_day + 8.hours) }

  describe ".call" do
    context "with valid params and available tee time" do
      it "creates a booking successfully" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )

        expect(result).to be_success
        expect(result.data.booking).to be_a(Booking)
        expect(result.data.booking.players_count).to eq(2)
        expect(result.data.booking.status).to eq("confirmed")
        expect(result.data.booking.confirmation_code).to be_present
      end

      it "creates booking players" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 3,
          player_names: ["Alice Smith", "Bob Jones", "Charlie Brown"]
        )

        expect(result).to be_success
        booking = result.data.booking
        expect(booking.booking_players.count).to eq(3)
        expect(booking.booking_players.map(&:name)).to include("Alice Smith", "Bob Jones", "Charlie Brown")
      end

      it "updates tee time booked players" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )

        tee_time.reload
        expect(tee_time.booked_players).to eq(2)
        expect(tee_time.status).to eq("partially_booked")
      end

      it "marks tee time as fully booked when all spots taken" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 4
        )

        tee_time.reload
        expect(tee_time.status).to eq("fully_booked")
      end
    end

    context "when tee time is unavailable" do
      let(:tee_time) { create(:tee_time, :fully_booked, tee_sheet: tee_sheet) }

      it "returns failure" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 1
        )

        expect(result).to be_failure
        expect(result.errors).to include("This tee time is fully booked")
      end
    end

    context "when requesting more players than available spots" do
      let(:tee_time) { create(:tee_time, :partially_booked, tee_sheet: tee_sheet) }

      it "returns failure" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 4
        )

        expect(result).to be_failure
        expect(result.errors.first).to include("spots available")
      end
    end

    context "when tee time is blocked" do
      let(:tee_time) { create(:tee_time, :blocked, tee_sheet: tee_sheet) }

      it "returns failure" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )

        expect(result).to be_failure
        expect(result.errors).to include("This tee time is blocked")
      end
    end

    context "when tee time is in the past" do
      let(:tee_time) { create(:tee_time, :past, tee_sheet: tee_sheet) }

      it "returns failure" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )

        expect(result).to be_failure
        expect(result.errors).to include("Cannot book tee times in the past")
      end
    end

    context "with payment processing" do
      before do
        allow(Payments::ProcessPaymentService).to receive(:call).and_return(
          ServiceResult.new(success: true, data: { payment: build(:payment) })
        )
      end

      it "processes payment when payment_method_id provided" do
        result = described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2,
          payment_method_id: "pm_test_123"
        )

        expect(result).to be_success
        expect(Payments::ProcessPaymentService).to have_received(:call)
      end
    end

    context "with notification sending" do
      before do
        allow(Notifications::SendBookingConfirmationService).to receive(:call).and_return(
          ServiceResult.new(success: true, data: { delivered: true })
        )
      end

      it "sends booking confirmation" do
        described_class.call(
          organization: organization,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )

        expect(Notifications::SendBookingConfirmationService).to have_received(:call)
      end
    end
  end
end
