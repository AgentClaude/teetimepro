# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeeSheets::SearchTeeTimesService do
  let(:organization) { create(:organization, timezone: "America/Denver") }
  let(:other_organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:other_course) { create(:course, organization: other_organization) }

  let(:target_date) { Date.new(2026, 3, 10) } # Tuesday
  let(:tee_sheet) { create(:tee_sheet, course: course, date: target_date) }

  # Morning tee times (8am, 9am, 10am)
  let!(:morning_8am) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 8),
      max_players: 4, booked_players: 0, status: :available, price_cents: 7500)
  end

  let!(:morning_9am) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 9),
      max_players: 4, booked_players: 2, status: :partially_booked, price_cents: 7500)
  end

  let!(:morning_10am) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 10),
      max_players: 4, booked_players: 0, status: :available, price_cents: 7500)
  end

  # Afternoon tee time (2pm)
  let!(:afternoon_2pm) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 14),
      max_players: 4, booked_players: 0, status: :available, price_cents: 6500)
  end

  # Twilight tee time (5pm)
  let!(:twilight_5pm) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 17),
      max_players: 4, booked_players: 0, status: :available, price_cents: 4500)
  end

  # Fully booked time
  let!(:fully_booked_11am) do
    create(:tee_time, tee_sheet: tee_sheet,
      starts_at: target_date.in_time_zone("America/Denver").change(hour: 11),
      max_players: 4, booked_players: 4, status: :fully_booked, price_cents: 7500)
  end

  describe ".call" do
    context "basic date + players search" do
      it "returns available tee times for the given date" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 2
        )

        expect(result).to be_success
        expect(result.tee_times).to be_an(Array)
        expect(result.tee_times.length).to eq(5) # all except fully_booked
      end

      it "filters by player availability" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 4
        )

        expect(result).to be_success
        # 9am has only 2 spots, fully_booked has 0 — both excluded
        expect(result.tee_times).not_to include(morning_9am)
        expect(result.tee_times).not_to include(fully_booked_11am)
        expect(result.tee_times.length).to eq(4)
      end
    end

    context "time preference filtering" do
      it "filters by morning preference" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 1,
          time_preference: "morning"
        )

        expect(result).to be_success
        result.tee_times.each do |tt|
          hour = tt.starts_at.in_time_zone("America/Denver").hour
          expect(hour).to be_between(7, 11)
        end
      end

      it "filters by afternoon preference" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 1,
          time_preference: "afternoon"
        )

        expect(result).to be_success
        expect(result.tee_times).to include(afternoon_2pm)
        result.tee_times.each do |tt|
          hour = tt.starts_at.in_time_zone("America/Denver").hour
          expect(hour).to be_between(12, 16)
        end
      end

      it "filters by twilight preference" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 1,
          time_preference: "twilight"
        )

        expect(result).to be_success
        expect(result.tee_times).to include(twilight_5pm)
      end

      it "filters by specific hour preference" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          players: 1,
          time_preference: "9"
        )

        expect(result).to be_success
        # Hour 9 → range 8-10, should include 8am, 9am, 10am (minus 10 which is at boundary)
        expect(result.tee_times).to include(morning_8am, morning_9am)
      end
    end

    context "multi-day range search" do
      let(:next_day) { target_date + 1.day }
      let(:next_sheet) { create(:tee_sheet, course: course, date: next_day) }

      let!(:next_day_time) do
        create(:tee_time, tee_sheet: next_sheet,
          starts_at: next_day.in_time_zone("America/Denver").change(hour: 9),
          max_players: 4, booked_players: 0, status: :available, price_cents: 7500)
      end

      it "returns tee times across multiple days" do
        result = described_class.call(
          organization: organization,
          start_date: target_date.to_s,
          end_date: next_day.to_s,
          players: 1
        )

        expect(result).to be_success
        dates = result.tee_times.map(&:date).uniq
        expect(dates).to include(target_date, next_day)
      end
    end

    context "alternative suggestions" do
      let(:empty_date) { Date.new(2026, 3, 15) } # No tee sheet for this date
      let(:prev_day) { empty_date - 1.day }
      let(:prev_sheet) { create(:tee_sheet, course: course, date: prev_day) }

      let!(:prev_day_time) do
        create(:tee_time, tee_sheet: prev_sheet,
          starts_at: prev_day.in_time_zone("America/Denver").change(hour: 9),
          max_players: 4, booked_players: 0, status: :available, price_cents: 7500)
      end

      it "returns alternatives when no results found for date" do
        result = described_class.call(
          organization: organization,
          date: empty_date.to_s,
          players: 1
        )

        expect(result).to be_success
        expect(result.tee_times).to be_empty
        expect(result.alternatives).to be_present
        expect(result.message).to include("No times available")
      end
    end

    context "organization scoping" do
      let(:other_sheet) { create(:tee_sheet, course: other_course, date: target_date) }

      let!(:other_org_time) do
        create(:tee_time, tee_sheet: other_sheet,
          starts_at: target_date.in_time_zone("UTC").change(hour: 9),
          max_players: 4, booked_players: 0, status: :available)
      end

      it "only returns tee times for the given organization" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s
        )

        expect(result).to be_success
        expect(result.tee_times).not_to include(other_org_time)
      end

      it "does not leak data across organizations" do
        result = described_class.call(
          organization: other_organization,
          date: target_date.to_s
        )

        expect(result).to be_success
        result.tee_times.each do |tt|
          expect(tt.course.organization_id).to eq(other_organization.id)
        end
      end
    end

    context "validation" do
      it "fails without an organization" do
        result = described_class.call(date: target_date.to_s)

        expect(result).to be_failure
      end
    end

    context "status filtering" do
      it "filters by available status" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          status: "available"
        )

        expect(result).to be_success
        result.tee_times.each do |tt|
          expect(tt.status).to be_in(%w[available partially_booked])
        end
      end

      it "filters by fully_booked status" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          status: "fully_booked"
        )

        expect(result).to be_success
        expect(result.tee_times).to include(fully_booked_11am)
        result.tee_times.each do |tt|
          expect(tt.status).to eq("fully_booked")
        end
      end
    end

    context "course filtering" do
      let(:second_course) { create(:course, organization: organization) }
      let(:second_sheet) { create(:tee_sheet, course: second_course, date: target_date) }

      let!(:second_course_time) do
        create(:tee_time, tee_sheet: second_sheet,
          starts_at: target_date.in_time_zone("America/Denver").change(hour: 8),
          max_players: 4, booked_players: 0, status: :available)
      end

      it "filters by course_id" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          course_id: second_course.id
        )

        expect(result).to be_success
        result.tee_times.each do |tt|
          expect(tt.course.id).to eq(second_course.id)
        end
      end
    end

    context "limit" do
      it "respects custom limit" do
        result = described_class.call(
          organization: organization,
          date: target_date.to_s,
          limit: 2
        )

        expect(result).to be_success
        expect(result.tee_times.length).to be <= 2
      end
    end
  end
end
