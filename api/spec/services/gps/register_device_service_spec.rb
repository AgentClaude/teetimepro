require "rails_helper"

RSpec.describe Gps::RegisterDeviceService do
  let(:organization) { create(:organization) }

  describe ".call" do
    context "registering a new device" do
      it "creates the device" do
        result = described_class.call(
          organization: organization,
          device_id: "GPS-001",
          name: "Cart GPS #1",
          device_type: :cart_gps,
          firmware_version: "2.1.0"
        )

        expect(result).to be_success
        expect(result.data[:device]).to be_persisted
        expect(result.data[:device].name).to eq("Cart GPS #1")
        expect(result.data[:device].cart_gps?).to be true
        expect(result.data[:device].active?).to be true
        expect(result.data[:newly_registered]).to be true
      end
    end

    context "re-registering an existing device" do
      it "updates the existing device" do
        create(:rangefinder_device,
          organization: organization,
          device_id: "GPS-001",
          name: "Old Name",
          device_type: :cart_gps
        )

        result = described_class.call(
          organization: organization,
          device_id: "GPS-001",
          name: "New Name",
          device_type: :cart_gps,
          firmware_version: "3.0.0"
        )

        expect(result).to be_success
        expect(result.data[:device].name).to eq("New Name")
        expect(result.data[:device].firmware_version).to eq("3.0.0")
        expect(result.data[:newly_registered]).to be false
        expect(RangefinderDevice.where(organization: organization, device_id: "GPS-001").count).to eq(1)
      end
    end

    context "with missing params" do
      it "returns failure without device_id" do
        result = described_class.call(
          organization: organization,
          device_id: nil,
          name: "GPS Unit",
          device_type: :cart_gps
        )

        expect(result).to be_failure
      end
    end
  end
end
