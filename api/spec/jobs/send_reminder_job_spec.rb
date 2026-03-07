# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderJob do
  describe "#perform" do
    context "batch mode (no arguments)" do
      it "calls Reminders::SendReminderService" do
        expect(Reminders::SendReminderService).to receive(:call).and_return(
          ServiceResult.new(success: true, data: { reminders_24h: 0, morning_reminders: 0, errors: [] })
        )

        described_class.new.perform
      end
    end

    context "single booking mode (with booking_id)" do
      let(:organization) { create(:organization) }
      let(:course) { create(:course, organization: organization) }
      let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.tomorrow) }
      let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 24.hours.from_now) }

      it "sends reminder for a valid upcoming booking" do
        booking = create(:booking, tee_time: tee_time, status: :confirmed)

        expect(Notifications::SendReminderService).to receive(:call).with(booking: booking)

        described_class.new.perform(booking.id)
      end

      it "skips cancelled bookings" do
        booking = create(:booking, :cancelled, tee_time: tee_time)

        expect(Notifications::SendReminderService).not_to receive(:call)

        described_class.new.perform(booking.id)
      end

      it "skips past bookings" do
        past_tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 2.hours.ago)
        booking = create(:booking, tee_time: past_tee_time, status: :confirmed)

        expect(Notifications::SendReminderService).not_to receive(:call)

        described_class.new.perform(booking.id)
      end

      it "handles missing booking gracefully" do
        expect(Notifications::SendReminderService).not_to receive(:call)

        described_class.new.perform(999_999)
      end
    end
  end

  it "uses the notifications queue" do
    expect(described_class.new.queue_name).to eq("notifications")
  end
end
