require "rails_helper"

RSpec.describe Gps::CreateCourseGpsFeatureService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:course_hole) { create(:course_hole, course: course, hole_number: 1, par: 4) }

  describe ".call" do
    context "with valid params" do
      it "creates a GPS feature" do
        result = described_class.call(
          course_hole: course_hole,
          feature_type: :green_center,
          name: "Green Center",
          latitude: 33.4484,
          longitude: -112.074
        )

        expect(result).to be_success
        feature = result.data[:gps_feature]
        expect(feature).to be_persisted
        expect(feature.name).to eq("Green Center")
        expect(feature.green_center?).to be true
        expect(feature.latitude).to eq(33.4484)
      end

      it "creates a feature with optional fields" do
        result = described_class.call(
          course_hole: course_hole,
          feature_type: :bunker,
          name: "Fairway Bunker",
          latitude: 33.4484,
          longitude: -112.074,
          elevation_feet: 250.5,
          distance_from_tee_yards: 180,
          metadata: { depth: "shallow" }
        )

        expect(result).to be_success
        feature = result.data[:gps_feature]
        expect(feature.elevation_feet).to eq(250.5)
        expect(feature.distance_from_tee_yards).to eq(180)
        expect(feature.metadata["depth"]).to eq("shallow")
      end
    end

    context "with invalid params" do
      it "returns failure when name is missing" do
        result = described_class.call(
          course_hole: course_hole,
          feature_type: :green_center,
          name: nil,
          latitude: 33.4484,
          longitude: -112.074
        )

        expect(result).to be_failure
      end

      it "returns failure when coordinates are missing" do
        result = described_class.call(
          course_hole: course_hole,
          feature_type: :green_center,
          name: "Green",
          latitude: nil,
          longitude: nil
        )

        expect(result).to be_failure
      end
    end
  end
end
