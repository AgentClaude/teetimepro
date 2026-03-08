# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrepaidPurchase, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:prepaid_package) }
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:payment).optional }
    it { is_expected.to have_many(:prepaid_redemptions) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:purchased_at) }
  end

  describe "#usable?" do
    it "returns true for active, non-expired purchase" do
      purchase = build(:prepaid_purchase, status: :active, expires_at: 30.days.from_now)
      expect(purchase.usable?).to be true
    end

    it "returns false for expired purchase" do
      purchase = build(:prepaid_purchase, :expired)
      expect(purchase.usable?).to be false
    end

    it "returns false for cancelled purchase" do
      purchase = build(:prepaid_purchase, status: :cancelled)
      expect(purchase.usable?).to be false
    end
  end

  describe "#has_rounds?" do
    it "returns true when rounds remain" do
      purchase = build(:prepaid_purchase, rounds_remaining: 5)
      expect(purchase.has_rounds?).to be true
    end

    it "returns false when no rounds remain" do
      purchase = build(:prepaid_purchase, rounds_remaining: 0)
      expect(purchase.has_rounds?).to be false
    end

    it "returns true for time_pass regardless" do
      purchase = build(:prepaid_purchase, :time_pass)
      expect(purchase.has_rounds?).to be true
    end
  end

  describe "#has_balance?" do
    it "returns true when balance exists" do
      purchase = build(:prepaid_purchase, :value_card)
      expect(purchase.has_balance?).to be true
    end

    it "returns false when balance is zero" do
      purchase = build(:prepaid_purchase, :value_card)
      purchase.balance_cents = 0
      expect(purchase.has_balance?).to be false
    end
  end

  describe "#code generation" do
    it "auto-generates a code on create" do
      purchase = create(:prepaid_purchase)
      expect(purchase.code).to match(/\APP-[A-Z0-9]{8}\z/)
    end
  end
end
