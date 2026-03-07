require "rails_helper"

RSpec.describe MarketplaceConnection, type: :model do
  subject { build(:marketplace_connection) }

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_many(:marketplace_listings).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_inclusion_of(:provider).in_array(MarketplaceConnection::PROVIDERS) }

    it "validates uniqueness of provider per org and course" do
      existing = create(:marketplace_connection)
      duplicate = build(:marketplace_connection,
        organization: existing.organization,
        course: existing.course,
        provider: existing.provider
      )
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:provider]).to include("already connected for this course")
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, active: 1, paused: 2, error: 3) }
  end

  describe "scopes" do
    let(:org) { create(:organization) }
    let!(:active_connection) { create(:marketplace_connection, organization: org, status: :active) }
    let!(:paused_connection) { create(:marketplace_connection, :teeoff, organization: org, status: :paused) }

    describe ".for_organization" do
      it "returns connections for the given org" do
        expect(described_class.for_organization(org)).to include(active_connection, paused_connection)
      end
    end

    describe ".syncable" do
      it "returns only active connections" do
        expect(described_class.syncable).to include(active_connection)
        expect(described_class.syncable).not_to include(paused_connection)
      end
    end
  end

  describe "#effective_settings" do
    it "merges custom settings with defaults" do
      connection = build(:marketplace_connection, settings: { "discount_percent" => 15 })
      settings = connection.effective_settings

      expect(settings["discount_percent"]).to eq(15)
      expect(settings["auto_syndicate"]).to eq(true)
      expect(settings["min_advance_hours"]).to eq(4)
    end
  end

  describe "#provider_label" do
    it "returns human-readable label for golfnow" do
      expect(build(:marketplace_connection, provider: "golfnow").provider_label).to eq("GolfNow")
    end

    it "returns human-readable label for teeoff" do
      expect(build(:marketplace_connection, provider: "teeoff").provider_label).to eq("TeeOff")
    end
  end

  describe "#record_sync!" do
    it "updates last_synced_at and clears errors" do
      connection = create(:marketplace_connection, :error)
      connection.record_sync!

      expect(connection.last_synced_at).to be_within(1.second).of(Time.current)
      expect(connection.last_error).to be_nil
    end
  end

  describe "#record_error!" do
    it "sets error status and message" do
      connection = create(:marketplace_connection)
      connection.record_error!("API timeout")

      expect(connection.status).to eq("error")
      expect(connection.last_error).to eq("API timeout")
    end
  end
end
