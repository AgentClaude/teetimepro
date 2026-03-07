require "rails_helper"

RSpec.describe MarketplaceListing, type: :model do
  subject { build(:marketplace_listing) }

  describe "associations" do
    it { is_expected.to belong_to(:marketplace_connection) }
    it { is_expected.to belong_to(:tee_time) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(pending: 0, listed: 1, booked: 2, expired: 3, error: 4, cancelled: 5)
    end
  end

  describe "scopes" do
    let(:connection) { create(:marketplace_connection) }
    let!(:listed) { create(:marketplace_listing, marketplace_connection: connection, status: :listed) }
    let!(:pending) { create(:marketplace_listing, :pending, marketplace_connection: connection) }
    let!(:booked) { create(:marketplace_listing, :booked, marketplace_connection: connection) }

    describe ".active_listings" do
      it "returns pending and listed listings" do
        expect(described_class.active_listings).to include(listed, pending)
        expect(described_class.active_listings).not_to include(booked)
      end
    end
  end

  describe "#commission_rate_percent" do
    it "converts basis points to percent" do
      listing = build(:marketplace_listing, commission_rate_bps: 1500)
      expect(listing.commission_rate_percent).to eq(15.0)
    end

    it "returns 0 when nil" do
      listing = build(:marketplace_listing, commission_rate_bps: nil)
      expect(listing.commission_rate_percent).to eq(0)
    end
  end

  describe "#estimated_commission_cents" do
    it "calculates commission from price and rate" do
      listing = build(:marketplace_listing, listed_price_cents: 10000, commission_rate_bps: 1500)
      expect(listing.estimated_commission_cents).to eq(1500)
    end
  end

  describe "#net_revenue_cents" do
    it "subtracts commission from listed price" do
      listing = build(:marketplace_listing, listed_price_cents: 10000, commission_rate_bps: 1500)
      expect(listing.net_revenue_cents).to eq(8500)
    end
  end

  describe "#mark_listed!" do
    it "updates status and external ID" do
      listing = create(:marketplace_listing, :pending)
      listing.mark_listed!("ext_123")

      expect(listing.status).to eq("listed")
      expect(listing.external_listing_id).to eq("ext_123")
      expect(listing.listed_at).to be_present
    end
  end

  describe "#mark_booked!" do
    it "sets status to booked" do
      listing = create(:marketplace_listing)
      listing.mark_booked!
      expect(listing.status).to eq("booked")
    end
  end
end
