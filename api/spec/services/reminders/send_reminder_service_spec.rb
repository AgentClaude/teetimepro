# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reminders::SendReminderService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  describe ".call" do
    context "24-hour reminders" do
      it "sends reminders for bookings 20-28 hours away" do
        tee_sheet = create(:tee_sheet, course: course, date: Date.tomorrow)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 24.hours.from_now)
        booking = create(:booking, tee_time: tee_time, status: :confirmed)

        expect { described_class.call }
          .to change { ActionMailer::Base.deliveries.count }.by(1)

        booking.reload
        expect(booking.reminder_sent_at).to be_present
      end

      it "does not send reminders for bookings already reminded" do
        tee_sheet = create(:tee_sheet, course: course, date: Date.tomorrow)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 24.hours.from_now)
        create(:booking, tee_time: tee_time, status: :confirmed, reminder_sent_at: 1.hour.ago)

        expect { described_class.call }
          .not_to change { ActionMailer::Base.deliveries.count }
      end

      it "does not send reminders for cancelled bookings" do
        tee_sheet = create(:tee_sheet, course: course, date: Date.tomorrow)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 24.hours.from_now)
        create(:booking, :cancelled, tee_time: tee_time)

        expect { described_class.call }
          .not_to change { ActionMailer::Base.deliveries.count }
      end

      it "does not send reminders for bookings outside the 20-28 hour window" do
        tee_sheet = create(:tee_sheet, course: course, date: Date.current + 3.days)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 3.days.from_now)
        create(:booking, tee_time: tee_time, status: :confirmed)

        expect { described_class.call }
          .not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "morning-of reminders" do
      it "sends morning reminders for today's bookings not yet reminded" do
        # Use a time that's definitely today and in the future
        future_today = Time.current.change(hour: 23, min: 50)
        next unless future_today > Time.current # skip if we're past 23:50

        tee_sheet = create(:tee_sheet, course: course, date: future_today.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: future_today)
        booking = create(:booking, tee_time: tee_time, status: :confirmed)

        expect { described_class.call }
          .to change { ActionMailer::Base.deliveries.count }.by(1)

        booking.reload
        expect(booking.morning_reminder_sent_at).to be_present
      end

      it "does not send morning reminders for already-reminded bookings" do
        future_today = Time.current.change(hour: 23, min: 50)
        tee_sheet = create(:tee_sheet, course: course, date: future_today.to_date)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: future_today)
        create(:booking, tee_time: tee_time, status: :confirmed, morning_reminder_sent_at: 1.hour.ago)

        expect { described_class.call }
          .not_to change { ActionMailer::Base.deliveries.count }
      end

      it "does not send morning reminders for past tee times" do
        tee_sheet = create(:tee_sheet, course: course, date: Date.current)
        tee_time = create(:tee_time, tee_sheet: tee_sheet, starts_at: 1.hour.ago)
        create(:booking, tee_time: tee_time, status: :confirmed)

        expect { described_class.call }
          .not_to change { ActionMailer::Base.deliveries.count }
      end
    end

    context "combined scenario" do
      it "sends both types of reminders in one run" do
        # 24h reminder candidate
        tomorrow_sheet = create(:tee_sheet, course: course, date: Date.tomorrow)
        tomorrow_time = create(:tee_time, tee_sheet: tomorrow_sheet, starts_at: 24.hours.from_now)
        create(:booking, tee_time: tomorrow_time, status: :confirmed)

        # Morning reminder candidate - use a time clearly today and in the future
        future_today = Time.current.change(hour: 23, min: 50)
        today_sheet = create(:tee_sheet, course: course, date: future_today.to_date)
        today_time = create(:tee_time, tee_sheet: today_sheet, starts_at: future_today)
        create(:booking, tee_time: today_time, status: :confirmed)

        result = described_class.call

        expect(result).to be_success
        expect(result.data[:reminders_24h]).to eq(1)
        expect(result.data[:morning_reminders]).to eq(1)
        expect(result.data[:errors]).to be_empty
      end
    end

    context "error handling" do
      it "continues processing when one reminder fails" do
        # Use 24h window for reliability (avoids timezone edge cases)
        tee_sheet = create(:tee_sheet, course: course, date: Date.tomorrow)
        tee_time1 = create(:tee_time, tee_sheet: tee_sheet, starts_at: 23.hours.from_now)
        tee_time2 = create(:tee_time, tee_sheet: tee_sheet, starts_at: 24.hours.from_now)

        booking1 = create(:booking, tee_time: tee_time1, status: :confirmed)
        booking2 = create(:booking, tee_time: tee_time2, status: :confirmed)

        # Make first booking fail
        call_count = 0
        allow(BookingReminderMailer).to receive(:reminder_24h).and_wrap_original do |method, **args|
          call_count += 1
          if call_count == 1
            raise StandardError, "SMTP error"
          else
            method.call(**args)
          end
        end

        result = described_class.call

        expect(result).to be_success
        expect(result.data[:errors].size).to eq(1)
        expect(result.data[:reminders_24h]).to eq(1)
      end
    end

    it "returns success with zero counts when no reminders needed" do
      result = described_class.call

      expect(result).to be_success
      expect(result.data[:reminders_24h]).to eq(0)
      expect(result.data[:morning_reminders]).to eq(0)
      expect(result.data[:errors]).to be_empty
    end
  end
end
