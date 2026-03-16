require "rails_helper"

RSpec.describe Bookings::CancelBookingService do
  let(:organization) { create(:organization, :with_stripe) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
  let(:tee_time) do
    create(:tee_time, :partially_booked,
      tee_sheet: tee_sheet,
      starts_at: 2.days.from_now,
      booked_players: 2
    )
  end
  let(:booking) do
    create(:booking,
      tee_time: tee_time,
      user: user,
      players_count: 2,
      status: :confirmed
    )
  end

  before do
    # Stub external side-effects by default
    allow(Notifications::SendBookingEmailService).to receive(:call).and_return(
      ServiceResult.new(success: true, data: {})
    )
    allow(Waitlists::NotifyService).to receive(:call).and_return(
      ServiceResult.new(success: true, data: {})
    )
    allow(CalendarSyncJob).to receive(:perform_later)
    allow(ActionCable.server).to receive(:broadcast)
  end

  describe ".call" do
    context "with a valid confirmed booking" do
      it "cancels the booking" do
        result = described_class.call(booking: booking, reason: "Changed plans")

        expect(result).to be_success
        expect(booking.reload.status).to eq("cancelled")
        expect(booking.cancelled_at).to be_present
        expect(booking.cancellation_reason).to eq("Changed plans")
      end

      it "releases tee time spots" do
        described_class.call(booking: booking)

        tee_time.reload
        expect(tee_time.booked_players).to eq(0)
        expect(tee_time.status).to eq("available")
      end

      it "sends a cancellation notification" do
        described_class.call(booking: booking)

        expect(Notifications::SendBookingEmailService).to have_received(:call).with(
          booking: booking,
          email_type: "cancellation"
        )
      end

      it "broadcasts a real-time notification" do
        described_class.call(booking: booking)

        expect(ActionCable.server).to have_received(:broadcast).with(
          "notifications_#{organization.id}",
          hash_including(type: "booking.cancelled")
        )
      end

      it "enqueues calendar sync deletion" do
        described_class.call(booking: booking)

        expect(CalendarSyncJob).to have_received(:perform_later).with(booking.id, "delete")
      end

      it "notifies waitlisted users" do
        described_class.call(booking: booking)

        expect(Waitlists::NotifyService).to have_received(:call).with(tee_time: tee_time)
      end
    end

    context "when booking is already cancelled" do
      let(:booking) do
        create(:booking, :cancelled,
          tee_time: tee_time,
          user: user,
          players_count: 2
        )
      end

      it "returns failure" do
        result = described_class.call(booking: booking)

        expect(result).to be_failure
        expect(result.errors).to include("Booking is already cancelled")
      end
    end

    context "when booking is in the past" do
      let(:past_tee_time) do
        create(:tee_time, :past, tee_sheet: tee_sheet, booked_players: 2)
      end
      let(:booking) do
        create(:booking,
          tee_time: past_tee_time,
          user: user,
          players_count: 2,
          status: :confirmed
        )
      end

      it "returns failure" do
        result = described_class.call(booking: booking)

        expect(result).to be_failure
        expect(result.errors).to include("Cannot cancel past bookings")
      end
    end

    context "when booking is nil" do
      it "returns validation failure" do
        result = described_class.call(booking: nil)

        expect(result).to be_failure
        expect(result.errors.first).to include("Booking")
      end
    end

    context "with refund requested" do
      let(:booking) do
        b = create(:booking,
          tee_time: tee_time,
          user: user,
          players_count: 2,
          status: :confirmed
        )
        create(:payment, :completed, booking: b, amount_cents: b.total_cents)
        b
      end

      before do
        allow(Payments::RefundPaymentService).to receive(:call).and_return(
          ServiceResult.new(success: true, data: { refund: double("Refund") })
        )
      end

      it "processes refund when payment exists and refund requested" do
        result = described_class.call(
          booking: booking,
          reason: "Changed plans",
          refund: true
        )

        expect(result).to be_success
        expect(Payments::RefundPaymentService).to have_received(:call)
      end

      it "does not process refund when not requested" do
        result = described_class.call(booking: booking, refund: false)

        expect(result).to be_success
        expect(Payments::RefundPaymentService).not_to have_received(:call)
      end
    end

    context "when refund fails" do
      let(:booking) do
        b = create(:booking,
          tee_time: tee_time,
          user: user,
          players_count: 2,
          status: :confirmed
        )
        create(:payment, :completed, booking: b, amount_cents: b.total_cents)
        b
      end

      before do
        allow(Payments::RefundPaymentService).to receive(:call).and_return(
          ServiceResult.new(success: false, errors: ["Stripe refund failed"])
        )
      end

      it "rolls back the cancellation" do
        result = described_class.call(booking: booking, refund: true)

        # The transaction should rollback
        expect(booking.reload.status).to eq("confirmed")
      end
    end

    context "with late cancellation" do
      let(:tee_time) do
        create(:tee_time, :partially_booked,
          tee_sheet: tee_sheet,
          starts_at: 12.hours.from_now,
          booked_players: 2
        )
      end

      it "still allows cancellation but logs late cancel" do
        expect(Rails.logger).to receive(:info).with(/Late cancellation/).at_least(:once)
        allow(Rails.logger).to receive(:info) # allow other info logs

        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(booking.reload.status).to eq("cancelled")
      end
    end

    context "when cancellation reason is provided" do
      it "stores the reason" do
        result = described_class.call(
          booking: booking,
          reason: "Weather forecast is terrible"
        )

        expect(result).to be_success
        expect(booking.reload.cancellation_reason).to eq("Weather forecast is terrible")
      end
    end

    context "when cancellation reason is nil" do
      it "cancels without a reason" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        expect(booking.reload.cancellation_reason).to be_nil
      end
    end

    context "with multiple bookings on the same tee time" do
      let(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: 2.days.from_now,
          booked_players: 4,
          status: :fully_booked
        )
      end
      let(:booking) do
        create(:booking,
          tee_time: tee_time,
          user: user,
          players_count: 2,
          status: :confirmed
        )
      end

      it "partially releases spots and updates tee time status" do
        result = described_class.call(booking: booking)

        expect(result).to be_success
        tee_time.reload
        expect(tee_time.booked_players).to eq(2)
        expect(tee_time.status).to eq("partially_booked")
      end
    end
  end
end
