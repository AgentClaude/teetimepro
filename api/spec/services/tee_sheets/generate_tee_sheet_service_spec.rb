require "rails_helper"

RSpec.describe TeeSheets::GenerateTeeSheetService do
  let(:organization) { create(:organization) }
  let(:course) do
    create(:course,
      organization: organization,
      first_tee_time: Time.zone.parse("06:00"),
      last_tee_time: Time.zone.parse("17:00"),
      interval_minutes: 10,
      max_players_per_slot: 4,
      weekday_rate_cents: 7500,
      weekend_rate_cents: 9500,
      twilight_rate_cents: 4500
    )
  end

  let(:weekday_date) { Date.new(2026, 3, 9) }  # Monday
  let(:weekend_date) { Date.new(2026, 3, 7) }   # Saturday

  describe ".call" do
    context "with valid parameters" do
      it "creates a tee sheet for the given date" do
        result = described_class.call(course: course, date: weekday_date)

        expect(result).to be_success
        expect(result.data.tee_sheet).to be_persisted
        expect(result.data.tee_sheet.date).to eq(weekday_date)
        expect(result.data.tee_sheet.course).to eq(course)
      end

      it "generates correct number of tee times for 10-minute intervals" do
        # 06:00 to 17:00 at 10-min intervals = 67 tee times (inclusive)
        result = described_class.call(course: course, date: weekday_date)

        expect(result).to be_success
        expect(result.data.tee_times_count).to eq(67)
      end

      it "generates correct number of tee times for 8-minute intervals" do
        course.update!(interval_minutes: 8)
        # 06:00 to 17:00 = 660 minutes / 8 = 82.5 → 83 slots (inclusive of first)
        result = described_class.call(course: course, date: weekday_date)

        expect(result).to be_success
        expect(result.data.tee_times_count).to eq(83)
      end

      it "generates correct number of tee times for 15-minute intervals" do
        course.update!(interval_minutes: 15)
        # 06:00 to 17:00 = 660 minutes / 15 = 44 + 1 = 45 slots
        result = described_class.call(course: course, date: weekday_date)

        expect(result).to be_success
        expect(result.data.tee_times_count).to eq(45)
      end

      it "sets all tee times as available with 0 booked players" do
        result = described_class.call(course: course, date: weekday_date)

        tee_sheet = result.data.tee_sheet
        tee_sheet.tee_times.each do |tt|
          expect(tt.status).to eq("available")
          expect(tt.booked_players).to eq(0)
          expect(tt.max_players).to eq(4)
        end
      end

      it "sets first tee time at course.first_tee_time" do
        result = described_class.call(course: course, date: weekday_date)

        first_tt = result.data.tee_sheet.tee_times.order(:starts_at).first
        expect(first_tt.starts_at.strftime("%H:%M")).to eq("06:00")
      end

      it "sets last tee time at or before course.last_tee_time" do
        result = described_class.call(course: course, date: weekday_date)

        last_tt = result.data.tee_sheet.tee_times.order(:starts_at).last
        expect(last_tt.starts_at.strftime("%H:%M")).to eq("17:00")
      end
    end

    context "weekday vs weekend pricing" do
      it "applies weekday rate on weekdays" do
        result = described_class.call(course: course, date: weekday_date)

        morning_time = result.data.tee_sheet.tee_times.order(:starts_at).first
        expect(morning_time.price_cents).to eq(7500)
      end

      it "applies weekend rate on weekends" do
        result = described_class.call(course: course, date: weekend_date)

        morning_time = result.data.tee_sheet.tee_times.order(:starts_at).first
        expect(morning_time.price_cents).to eq(9500)
      end
    end

    context "twilight pricing" do
      before do
        # Stub twilight_time? on the course to treat 15:00+ as twilight
        allow(course).to receive(:twilight_start_time).and_return(Time.zone.parse("15:00"))
        allow(course).to receive(:respond_to?).and_call_original
        allow(course).to receive(:respond_to?).with(:twilight_start_time).and_return(true)
      end

      it "applies twilight rate after twilight start time on weekdays" do
        result = described_class.call(course: course, date: weekday_date)

        twilight_time = result.data.tee_sheet.tee_times
          .where("starts_at >= ?", Time.zone.parse("#{weekday_date} 15:00"))
          .order(:starts_at).first

        expect(twilight_time.price_cents).to eq(4500)
      end

      it "applies regular rate before twilight start time" do
        result = described_class.call(course: course, date: weekday_date)

        morning_time = result.data.tee_sheet.tee_times
          .where("starts_at < ?", Time.zone.parse("#{weekday_date} 15:00"))
          .order(:starts_at).first

        expect(morning_time.price_cents).to eq(7500)
      end
    end

    context "idempotency" do
      it "returns existing tee sheet if already generated" do
        first_result = described_class.call(course: course, date: weekday_date)
        expect(first_result).to be_success
        expect(first_result.data.already_existed).to be false

        second_result = described_class.call(course: course, date: weekday_date)
        expect(second_result).to be_success
        expect(second_result.data.already_existed).to be true
        expect(second_result.data.tee_sheet.id).to eq(first_result.data.tee_sheet.id)
      end

      it "does not create duplicate tee times when run twice" do
        described_class.call(course: course, date: weekday_date)
        described_class.call(course: course, date: weekday_date)

        expect(TeeSheet.where(course: course, date: weekday_date).count).to eq(1)
        expect(TeeTime.joins(:tee_sheet).where(tee_sheets: { course: course, date: weekday_date }).count).to eq(67)
      end
    end

    context "edge cases" do
      it "fails when course is nil" do
        result = described_class.call(course: nil, date: weekday_date)
        expect(result).to be_failure
      end

      it "fails when date is nil" do
        result = described_class.call(course: course, date: nil)
        expect(result).to be_failure
      end

      it "fails when first_tee_time is not configured" do
        course.update_column(:first_tee_time, nil)
        result = described_class.call(course: course, date: weekday_date)
        expect(result).to be_failure
        expect(result.error_message).to match(/first_tee_time/)
      end

      it "fails when last_tee_time is not configured" do
        course.update_column(:last_tee_time, nil)
        result = described_class.call(course: course, date: weekday_date)
        expect(result).to be_failure
        expect(result.error_message).to match(/last_tee_time/)
      end
    end

    context "with blocked times" do
      it "marks specified time ranges as blocked" do
        result = described_class.call(
          course: course,
          date: weekday_date,
          blocked_times: [
            { start: "12:00", end: "13:00", reason: "Tournament" }
          ]
        )

        expect(result).to be_success
        blocked = result.data.tee_sheet.tee_times.where(status: :blocked)
        expect(blocked.count).to be > 0
        expect(blocked.first.notes).to eq("Tournament")
      end
    end
  end
end
