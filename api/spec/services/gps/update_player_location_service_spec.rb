require "rails_helper"

RSpec.describe Gps::UpdatePlayerLocationService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.today) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }
  let(:booking) { create(:booking, tee_time: tee_time, status: :confirmed) }

  describe ".call" do
    context "with valid params and active booking" do
      it "creates a player location" do
        result = described_class.call(
          booking: booking,
          latitude: 33.4484,
          longitude: -112.074,
          current_hole: 5
        )

        expect(result).to be_success
        location = result.data[:player_location]
        expect(location).to be_persisted
        expect(location.latitude.to_f).to eq(33.4484)
        expect(location.current_hole).to eq(5)
        expect(location.course).to eq(course)
      end

      it "returns distances when on a hole with GPS features" do
        hole = create(:course_hole, course: course, hole_number: 5, par: 4)
        create(:course_gps_feature, course_hole: hole, feature_type: :green_center,
               name: "Green Center", latitude: 33.4490, longitude: -112.074)

        result = described_class.call(
          booking: booking,
          latitude: 33.4484,
          longitude: -112.074,
          current_hole: 5
        )

        expect(result).to be_success
        expect(result.data[:distances]).not_to be_empty
        expect(result.data[:distances].first[:feature_name]).to eq("Green Center")
        expect(result.data[:distances].first[:distance_yards]).to be > 0
      end
    end

    context "with a rangefinder device" do
      it "associates the device and updates last_seen" do
        device = create(:rangefinder_device, organization: organization)

        result = described_class.call(
          booking: booking,
          latitude: 33.4484,
          longitude: -112.074,
          rangefinder_device: device
        )

        expect(result).to be_success
        expect(result.data[:player_location].rangefinder_device).to eq(device)
        expect(device.reload.last_seen_at).to be_within(2.seconds).of(Time.current)
      end
    end

    context "with cancelled booking" do
      let(:booking) { create(:booking, :cancelled, tee_time: tee_time) }

      it "returns failure" do
        result = described_class.call(
          booking: booking,
          latitude: 33.4484,
          longitude: -112.074
        )

        expect(result).to be_failure
        expect(result.errors).to include("Booking is not active")
      end
    end

    context "with missing coordinates" do
      it "returns failure" do
        result = described_class.call(
          booking: booking,
          latitude: nil,
          longitude: nil
        )

        expect(result).to be_failure
      end
    end
  end
end
