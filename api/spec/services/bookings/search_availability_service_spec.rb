require "rails_helper"

RSpec.describe Bookings::SearchAvailabilityService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:today) { Date.current }
  let(:tomorrow) { Date.current + 1.day }

  describe ".call" do
    context "with available slots" do
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:available_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          price_cents: 5000,
          status: :available)
      end
      let!(:partial_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 10),
          max_players: 4,
          booked_players: 2,
          price_cents: 5000,
          status: :partially_booked)
      end
      let!(:full_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 11),
          max_players: 4,
          booked_players: 4,
          price_cents: 5000,
          status: :fully_booked)
      end

      it "returns available and partially booked slots" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(2)
        expect(result.data[:total_available]).to eq(2)

        ids = result.data[:slots].map { |s| s[:tee_time_id] }
        expect(ids).to include(available_slot.id, partial_slot.id)
        expect(ids).not_to include(full_slot.id)
      end

      it "respects player count filtering" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 3
        )

        expect(result).to be_success
        # partial_slot only has 2 available spots, can't fit 3 players
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:tee_time_id]).to eq(available_slot.id)
      end

      it "includes pricing information" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 2,
          include_pricing: true
        )

        expect(result).to be_success
        slot = result.data[:slots].first
        expect(slot[:base_price_cents]).to eq(5000)
        expect(slot[:price_per_player_cents]).to be_present
        expect(slot[:total_price_cents]).to eq(slot[:price_per_player_cents] * 2)
      end

      it "includes course information" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        slot = result.data[:slots].first
        expect(slot[:course_name]).to eq(course.name)
        expect(slot[:course_id]).to eq(course.id)
        expect(slot[:formatted_time]).to be_present
      end

      it "returns date range metadata" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          end_date: tomorrow + 2.days,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:date_range][:start_date]).to eq(tomorrow)
        expect(result.data[:date_range][:end_date]).to eq(tomorrow + 2.days)
        expect(result.data[:date_range][:days]).to eq(3)
      end
    end

    context "with time preference filtering" do
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:morning_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 8),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end
      let!(:afternoon_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 14),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end
      let!(:twilight_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 17),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "filters to morning slots" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1,
          time_preference: "morning"
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:tee_time_id]).to eq(morning_slot.id)
      end

      it "filters to afternoon slots" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1,
          time_preference: "afternoon"
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:tee_time_id]).to eq(afternoon_slot.id)
      end

      it "filters to twilight slots" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1,
          time_preference: "twilight"
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:tee_time_id]).to eq(twilight_slot.id)
      end
    end

    context "with course_id filter" do
      let(:other_course) { create(:course, organization: organization) }
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:other_sheet) { create(:tee_sheet, course: other_course, date: tomorrow) }
      let!(:slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end
      let!(:other_slot) do
        create(:tee_time,
          tee_sheet: other_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "returns slots from all courses when no course_id" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(2)
      end

      it "scopes to specific course" do
        result = described_class.call(
          organization: organization,
          course_id: course.id,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:course_id]).to eq(course.id)
      end
    end

    context "with multi-day range" do
      let!(:sheet_day1) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:sheet_day2) { create(:tee_sheet, course: course, date: tomorrow + 1.day) }
      let!(:slot_day1) do
        create(:tee_time,
          tee_sheet: sheet_day1,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end
      let!(:slot_day2) do
        create(:tee_time,
          tee_sheet: sheet_day2,
          starts_at: (tomorrow + 1.day).in_time_zone("UTC").change(hour: 10),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "returns slots across date range" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          end_date: tomorrow + 1.day,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(2)
        dates = result.data[:slots].map { |s| s[:date] }.uniq
        expect(dates.size).to eq(2)
      end
    end

    context "excludes past tee times" do
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: today) }
      let!(:past_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: 2.hours.ago,
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "does not include past tee times" do
        result = described_class.call(
          organization: organization,
          date: today,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots]).to be_empty
      end
    end

    context "excludes blocked and maintenance slots" do
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:blocked_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :blocked)
      end
      let!(:maintenance_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 10),
          max_players: 4,
          booked_players: 0,
          status: :maintenance)
      end

      it "excludes blocked and maintenance slots" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots]).to be_empty
      end
    end

    context "organization scoping" do
      let(:other_org) { create(:organization) }
      let(:other_course) { create(:course, organization: other_org) }
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: tomorrow) }
      let!(:other_sheet) { create(:tee_sheet, course: other_course, date: tomorrow) }
      let!(:our_slot) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end
      let!(:their_slot) do
        create(:tee_time,
          tee_sheet: other_sheet,
          starts_at: tomorrow.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "only returns slots from the given organization" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots].size).to eq(1)
        expect(result.data[:slots].first[:tee_time_id]).to eq(our_slot.id)
      end
    end

    context "with no available slots" do
      it "returns empty results" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 1
        )

        expect(result).to be_success
        expect(result.data[:slots]).to be_empty
        expect(result.data[:total_available]).to eq(0)
      end
    end

    context "with invalid params" do
      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          date: tomorrow,
          players: 1
        )

        expect(result).not_to be_success
      end

      it "fails when date is missing" do
        result = described_class.call(
          organization: organization,
          date: nil,
          players: 1
        )

        expect(result).not_to be_success
      end

      it "fails when players is out of range" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          players: 6
        )

        expect(result).not_to be_success
      end

      it "fails when end_date is before date" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          end_date: today,
          players: 1
        )

        expect(result).not_to be_success
        expect(result.errors).to include("End date must be on or after start date")
      end

      it "fails when date range exceeds 30 days" do
        result = described_class.call(
          organization: organization,
          date: tomorrow,
          end_date: tomorrow + 31.days,
          players: 1
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Date range cannot exceed 30 days")
      end
    end
  end
end
