require "rails_helper"

RSpec.describe RangefinderDevice, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:player_locations).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:rangefinder_device) }

    it { is_expected.to validate_presence_of(:device_id) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:device_type) }
  end

  describe "uniqueness" do
    let(:org) { create(:organization) }

    it "prevents duplicate device_id per organization" do
      create(:rangefinder_device, organization: org, device_id: "ABC123")
      duplicate = build(:rangefinder_device, organization: org, device_id: "ABC123")
      expect(duplicate).not_to be_valid
    end

    it "allows same device_id in different organizations" do
      other_org = create(:organization)
      create(:rangefinder_device, organization: org, device_id: "ABC123")
      device = build(:rangefinder_device, organization: other_org, device_id: "ABC123")
      expect(device).to be_valid
    end
  end

  describe "enums" do
    it "defines device types" do
      expect(described_class.device_types).to include(
        "handheld_gps" => 0,
        "cart_gps" => 1,
        "watch_gps" => 2,
        "laser_rangefinder" => 3
      )
    end

    it "defines statuses" do
      expect(described_class.statuses).to include(
        "active" => 0,
        "inactive" => 1,
        "maintenance" => 2
      )
    end
  end

  describe "#online?" do
    it "returns true when active and recently seen" do
      device = build(:rangefinder_device, status: :active, last_seen_at: 5.minutes.ago)
      expect(device.online?).to be true
    end

    it "returns false when last seen too long ago" do
      device = build(:rangefinder_device, :offline)
      expect(device.online?).to be false
    end

    it "returns false when inactive" do
      device = build(:rangefinder_device, :inactive, last_seen_at: 1.minute.ago)
      expect(device.online?).to be false
    end
  end

  describe ".online scope" do
    let(:org) { create(:organization) }

    it "returns only active recently-seen devices" do
      online = create(:rangefinder_device, organization: org, last_seen_at: 5.minutes.ago)
      create(:rangefinder_device, :offline, organization: org)
      create(:rangefinder_device, :inactive, organization: org, last_seen_at: 1.minute.ago)

      expect(described_class.online).to contain_exactly(online)
    end
  end
end
