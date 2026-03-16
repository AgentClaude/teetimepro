require "rails_helper"

RSpec.describe CourseGpsFeature, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:course_hole) }
    it { is_expected.to have_one(:course).through(:course_hole) }
  end

  describe "validations" do
    subject { build(:course_gps_feature) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }
    it { is_expected.to validate_presence_of(:feature_type) }

    it "validates latitude range" do
      feature = build(:course_gps_feature, latitude: 91)
      expect(feature).not_to be_valid
    end

    it "validates longitude range" do
      feature = build(:course_gps_feature, longitude: 181)
      expect(feature).not_to be_valid
    end
  end

  describe "enums" do
    it "defines feature types" do
      expect(described_class.feature_types).to include(
        "tee_box" => 0,
        "green_center" => 1,
        "bunker" => 4,
        "water_hazard" => 5,
        "pin_position" => 9
      )
    end
  end

  describe "scopes" do
    let(:course) { create(:course) }
    let(:hole) { create(:course_hole, course: course, hole_number: 1, par: 4) }

    before do
      create(:course_gps_feature, course_hole: hole, feature_type: :green_center)
      create(:course_gps_feature, :bunker, course_hole: hole)
      create(:course_gps_feature, :water_hazard, course_hole: hole)
    end

    it ".hazards returns hazard features" do
      expect(described_class.hazards.count).to eq(2)
    end

    it ".targets returns target features" do
      expect(described_class.targets.count).to eq(1)
    end
  end

  describe "#coordinates" do
    it "returns lat/lng hash" do
      feature = build(:course_gps_feature, latitude: 33.4484, longitude: -112.074)
      expect(feature.coordinates).to eq({ latitude: 33.4484, longitude: -112.074 })
    end
  end

  describe "#distance_to" do
    it "calculates distance to a point" do
      feature = build(:course_gps_feature, latitude: 33.4484, longitude: -112.074)
      distance = feature.distance_to(33.4490, -112.074)
      expect(distance).to be_a(Float)
      expect(distance).to be > 0
    end
  end
end
