require "rails_helper"

RSpec.describe Dashboard::UtilizationHeatMapService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:start_date) { Date.new(2026, 3, 1) }
  let(:end_date) { Date.new(2026, 3, 7) }

  describe ".call" do
    context "with valid params" do
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: start_date) }
      let!(:tee_time_morning) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: start_date.in_time_zone("UTC").change(hour: 8),
          max_players: 4,
          booked_players: 3,
          status: :partially_booked)
      end
      let!(:tee_time_afternoon) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: start_date.in_time_zone("UTC").change(hour: 14),
          max_players: 4,
          booked_players: 1,
          status: :partially_booked)
      end

      it "returns heat map cells" do
        result = described_class.call(
          organization: organization,
          start_date: start_date,
          end_date: end_date
        )

        expect(result).to be_success
        expect(result.data[:cells]).to be_an(Array)
        expect(result.data[:cells].length).to eq(2)

        morning_cell = result.data[:cells].find { |c| c[:hour] == 8 }
        expect(morning_cell[:utilization_percentage]).to eq(75.0)
        expect(morning_cell[:booked_players]).to eq(3)
        expect(morning_cell[:total_capacity]).to eq(4)

        afternoon_cell = result.data[:cells].find { |c| c[:hour] == 14 }
        expect(afternoon_cell[:utilization_percentage]).to eq(25.0)
      end

      it "returns summary statistics" do
        result = described_class.call(
          organization: organization,
          start_date: start_date,
          end_date: end_date
        )

        expect(result).to be_success
        summary = result.data[:summary]
        expect(summary[:overall_utilization]).to eq(50.0)
        expect(summary[:total_booked_players]).to eq(4)
        expect(summary[:total_capacity]).to eq(8)
        expect(summary[:peak_hour]).to eq(8)
        expect(summary[:date_range_days]).to eq(7)
      end
    end

    context "with course_id filter" do
      let(:other_course) { create(:course, organization: organization) }
      let!(:tee_sheet) { create(:tee_sheet, course: course, date: start_date) }
      let!(:other_tee_sheet) { create(:tee_sheet, course: other_course, date: start_date) }
      let!(:tee_time) do
        create(:tee_time,
          tee_sheet: tee_sheet,
          starts_at: start_date.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 4,
          status: :fully_booked)
      end
      let!(:other_tee_time) do
        create(:tee_time,
          tee_sheet: other_tee_sheet,
          starts_at: start_date.in_time_zone("UTC").change(hour: 9),
          max_players: 4,
          booked_players: 0,
          status: :available)
      end

      it "scopes to the specified course" do
        result = described_class.call(
          organization: organization,
          course_id: course.id,
          start_date: start_date,
          end_date: end_date
        )

        expect(result).to be_success
        expect(result.data[:cells].length).to eq(1)
        expect(result.data[:cells].first[:utilization_percentage]).to eq(100.0)
      end
    end

    context "with no tee times" do
      it "returns empty cells and zero utilization" do
        result = described_class.call(
          organization: organization,
          start_date: start_date,
          end_date: end_date
        )

        expect(result).to be_success
        expect(result.data[:cells]).to be_empty
        expect(result.data[:summary][:overall_utilization]).to eq(0.0)
      end
    end

    context "with invalid params" do
      it "fails when organization is missing" do
        result = described_class.call(
          organization: nil,
          start_date: start_date,
          end_date: end_date
        )

        expect(result).not_to be_success
      end

      it "fails when date range exceeds 90 days" do
        result = described_class.call(
          organization: organization,
          start_date: start_date,
          end_date: start_date + 91.days
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Date range cannot exceed 90 days")
      end

      it "fails when start_date is after end_date" do
        result = described_class.call(
          organization: organization,
          start_date: end_date,
          end_date: start_date
        )

        expect(result).not_to be_success
        expect(result.errors).to include("Start date must be before end date")
      end
    end
  end
end
