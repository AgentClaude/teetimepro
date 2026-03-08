# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrepaidPackage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:course).optional }
    it { is_expected.to have_many(:prepaid_purchases) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price_cents) }

    context "when round_pack" do
      subject { build(:prepaid_package, package_type: :round_pack) }

      it { is_expected.to validate_presence_of(:rounds_included) }
    end

    context "when value_card" do
      subject { build(:prepaid_package, :value_card) }

      it { is_expected.to validate_presence_of(:value_cents) }
    end
  end

  describe "#available?" do
    it "returns true for active package with no date restrictions" do
      package = build(:prepaid_package)
      expect(package.available?).to be true
    end

    it "returns false for inactive package" do
      package = build(:prepaid_package, :inactive)
      expect(package.available?).to be false
    end

    it "returns false when availability window has passed" do
      package = build(:prepaid_package, :expired_availability)
      expect(package.available?).to be false
    end
  end

  describe "#valid_for_date?" do
    let(:package) { build(:prepaid_package, :with_restrictions) }

    it "returns false for restricted days" do
      saturday = Date.parse("2026-03-07") # Saturday
      expect(package.valid_for_date?(saturday)).to be false
    end

    it "returns true for unrestricted days" do
      monday = Date.parse("2026-03-09") # Monday
      expect(package.valid_for_date?(monday)).to be true
    end

    it "returns true when no restrictions" do
      unrestricted = build(:prepaid_package)
      expect(unrestricted.valid_for_date?(Date.today)).to be true
    end
  end

  describe "#valid_for_time?" do
    let(:package) { build(:prepaid_package, :with_restrictions) }

    it "returns true for times within range" do
      time = Time.zone.parse("2026-03-09 10:00")
      expect(package.valid_for_time?(time)).to be true
    end

    it "returns false for times outside range" do
      time = Time.zone.parse("2026-03-09 15:00")
      expect(package.valid_for_time?(time)).to be false
    end

    it "returns true when no time restrictions" do
      unrestricted = build(:prepaid_package)
      expect(unrestricted.valid_for_time?(Time.current)).to be true
    end
  end

  describe "scopes" do
    let(:org) { create(:organization) }

    it ".available returns only active packages within availability window" do
      active = create(:prepaid_package, organization: org)
      _inactive = create(:prepaid_package, :inactive, organization: org)
      _expired = create(:prepaid_package, :expired_availability, organization: org)

      expect(PrepaidPackage.available).to contain_exactly(active)
    end
  end
end
