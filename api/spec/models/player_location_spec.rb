require "rails_helper"

RSpec.describe PlayerLocation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:booking) }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to belong_to(:rangefinder_device).optional }
  end

  describe "validations" do
    subject { build(:player_location) }

    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }
    it { is_expected.to validate_presence_of(:recorded_at) }
  end

  describe "scopes" do
    it ".recent returns locations from the last hour" do
      org = create(:organization)
      course = create(:course, organization: org)
      recent = create(:player_location, course: course, recorded_at: 30.minutes.ago)
      create(:player_location, :stale, course: course)

      expect(described_class.recent).to contain_exactly(recent)
    end
  end

  describe "#coordinates" do
    it "returns lat/lng hash" do
      location = build(:player_location, latitude: 33.4484, longitude: -112.074)
      expect(location.coordinates).to eq({ latitude: 33.4484, longitude: -112.074 })
    end
  end
end
