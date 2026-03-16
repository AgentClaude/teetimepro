require "rails_helper"

RSpec.describe Gps::GetHoleOverviewService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:hole) { create(:course_hole, course: course, hole_number: 7, par: 4, yardage: 385) }

  before do
    create(:course_gps_feature, :tee_box, course_hole: hole,
           latitude: 33.4480, longitude: -112.074, distance_from_tee_yards: 0)
    create(:course_gps_feature, course_hole: hole,
           name: "Green Center", latitude: 33.4515, longitude: -112.074, distance_from_tee_yards: 385)
    create(:course_gps_feature, :bunker, course_hole: hole,
           latitude: 33.4510, longitude: -112.0738, distance_from_tee_yards: 350)
  end

  describe ".call" do
    context "without player position" do
      it "returns hole overview with features" do
        result = described_class.call(course: course, hole_number: 7)

        expect(result).to be_success
        overview = result.data[:overview]
        expect(overview[:hole_number]).to eq(7)
        expect(overview[:par]).to eq(4)
        expect(overview[:yardage]).to eq(385)
        expect(overview[:features].length).to eq(3)
        expect(overview[:distances]).to be_nil
      end
    end

    context "with player position" do
      it "includes distance calculations" do
        result = described_class.call(
          course: course,
          hole_number: 7,
          player_latitude: 33.4500,
          player_longitude: -112.074
        )

        expect(result).to be_success
        overview = result.data[:overview]
        expect(overview[:distances]).not_to be_empty
        expect(overview[:distances].first).to include(:feature_id, :feature_name, :distance_yards)
      end
    end

    context "with invalid hole number" do
      it "returns failure" do
        result = described_class.call(course: course, hole_number: 99)

        expect(result).to be_failure
        expect(result.errors).to include("Hole 99 not found")
      end
    end
  end
end
