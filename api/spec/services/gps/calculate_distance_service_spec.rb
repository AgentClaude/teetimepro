require "rails_helper"

RSpec.describe Gps::CalculateDistanceService do
  describe ".call" do
    context "with valid coordinates" do
      it "calculates distance between two points" do
        # Scottsdale, AZ to Phoenix, AZ (~10 miles apart)
        result = described_class.call(
          from_lat: 33.4942,
          from_lng: -111.9261,
          to_lat: 33.4484,
          to_lng: -112.0740
        )

        expect(result).to be_success
        expect(result.data[:distance_yards]).to be > 10_000
        expect(result.data[:distance_yards]).to be < 20_000
        expect(result.data[:distance_meters]).to be > 0
        expect(result.data[:distance_feet]).to be > 0
      end

      it "returns zero for same point" do
        result = described_class.call(
          from_lat: 33.4484, from_lng: -112.074,
          to_lat: 33.4484, to_lng: -112.074
        )

        expect(result).to be_success
        expect(result.data[:distance_yards]).to eq(0.0)
      end
    end

    context "with typical golf distances" do
      it "calculates a ~150 yard distance accurately" do
        # Points approximately 150 yards apart
        result = described_class.call(
          from_lat: 33.448400,
          from_lng: -112.074000,
          to_lat: 33.449651,
          to_lng: -112.074000
        )

        expect(result).to be_success
        expect(result.data[:distance_yards]).to be_within(20).of(150)
      end
    end

    context "with missing coordinates" do
      it "returns failure" do
        result = described_class.call(from_lat: nil, from_lng: -112.074, to_lat: 33.45, to_lng: -112.074)
        expect(result).to be_failure
      end
    end
  end

  describe ".haversine_yards" do
    it "is accessible as a class method" do
      distance = described_class.haversine_yards(33.4484, -112.074, 33.449, -112.074)
      expect(distance).to be_a(Float)
      expect(distance).to be > 0
    end
  end
end
