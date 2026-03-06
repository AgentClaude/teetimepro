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
      weekday_rate_cents: 7500
    )
  end
  let(:date) { Date.tomorrow }

  describe ".call" do
    context "with valid params" do
      it "creates a tee sheet for the given date" do
        result = described_class.call(course: course, date: date)

        expect(result).to be_success
        expect(result.data.tee_sheet).to be_a(TeeSheet)
        expect(result.data.tee_sheet.date).to eq(date)
        expect(result.data.tee_sheet.course).to eq(course)
      end

      it "generates correct number of tee times" do
        result = described_class.call(course: course, date: date)

        # 06:00 to 17:00 with 10-min intervals = 67 slots (inclusive)
        expect(result.data.tee_times_count).to be > 60
      end

      it "sets all tee times as available" do
        result = described_class.call(course: course, date: date)
        tee_sheet = result.data.tee_sheet

        expect(tee_sheet.tee_times.pluck(:status).uniq).to eq(["available"])
      end

      it "sets correct max players per slot" do
        result = described_class.call(course: course, date: date)
        tee_sheet = result.data.tee_sheet

        expect(tee_sheet.tee_times.pluck(:max_players).uniq).to eq([4])
      end

      it "sets booked players to zero" do
        result = described_class.call(course: course, date: date)
        tee_sheet = result.data.tee_sheet

        expect(tee_sheet.tee_times.pluck(:booked_players).uniq).to eq([0])
      end

      it "generates tee times in correct order" do
        result = described_class.call(course: course, date: date)
        tee_sheet = result.data.tee_sheet
        times = tee_sheet.tee_times.order(:starts_at).pluck(:starts_at)

        expect(times).to eq(times.sort)
        expect(times.first.hour).to eq(6)
        expect(times.first.min).to eq(0)
      end
    end

    context "when tee sheet already exists" do
      before do
        create(:tee_sheet, course: course, date: date)
      end

      it "returns failure" do
        result = described_class.call(course: course, date: date)

        expect(result).to be_failure
        expect(result.errors.first).to include("already exists")
      end
    end

    context "with blocked times" do
      it "marks specified times as blocked" do
        result = described_class.call(
          course: course,
          date: date,
          blocked_times: [
            { start: "12:00", end: "13:00", reason: "Tournament setup" }
          ]
        )

        expect(result).to be_success
        tee_sheet = result.data.tee_sheet
        blocked = tee_sheet.tee_times.where(status: :blocked)
        expect(blocked.count).to be > 0
        expect(blocked.first.notes).to eq("Tournament setup")
      end
    end

    context "with 8-minute intervals" do
      let(:course) { create(:course, :eight_minute_intervals, organization: organization) }

      it "generates more tee times than 10-minute intervals" do
        result_8 = described_class.call(course: course, date: date)
        expect(result_8.data.tee_times_count).to be > 67
      end
    end
  end
end
