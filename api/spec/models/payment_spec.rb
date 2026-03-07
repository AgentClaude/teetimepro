require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:booking) }
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to belong_to(:user).optional }
    it "has many accounting_syncs as syncable" do
      expect(Payment.reflect_on_association(:accounting_syncs)).to be_present
      expect(Payment.reflect_on_association(:accounting_syncs).macro).to eq(:has_many)
    end
  end

  describe "validations" do
    it "validates amount_cents is present and positive" do
      payment = build(:payment, amount_cents: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:amount_cents]).to be_present
    end

    it "validates amount_cents is greater than 0" do
      payment = build(:payment, amount_cents: 0)
      expect(payment).not_to be_valid
    end

    it "validates uniqueness of stripe_payment_intent_id" do
      existing = create(:payment)
      duplicate = build(:payment, stripe_payment_intent_id: existing.stripe_payment_intent_id)
      expect(duplicate).not_to be_valid
    end

    it "allows nil stripe_payment_intent_id" do
      payment = build(:payment, :manual)
      expect(payment).to be_valid
    end
  end

  describe "enums" do
    it "defines status enum" do
      expect(Payment.statuses).to include(
        "pending" => 0,
        "authorized" => 5,
        "captured" => 6,
        "refunded" => 3,
        "failed" => 2,
        "cancelled" => 7
      )
    end

    it "defines payment_method enum" do
      expect(Payment.payment_methods).to eq({
        "card" => 0,
        "cash" => 1,
        "account" => 2
      })
    end

    it "defines provider enum" do
      expect(Payment.providers).to eq({
        "stripe" => 0,
        "manual" => 1
      })
    end
  end

  describe "scopes" do
    let!(:payment) { create(:payment, :captured) }

    it ".for_booking filters by booking_id" do
      expect(Payment.for_booking(payment.booking_id)).to include(payment)
      expect(Payment.for_booking(0)).to be_empty
    end

    it ".by_status filters by status" do
      expect(Payment.by_status(:captured)).to include(payment)
      expect(Payment.by_status(:pending)).not_to include(payment)
    end
  end

  describe "#fully_refundable?" do
    it "returns true for captured payment with no refunds" do
      payment = build(:payment, :captured, refund_amount_cents: 0)
      expect(payment.fully_refundable?).to be true
    end

    it "returns false for pending payment" do
      payment = build(:payment, status: :pending)
      expect(payment.fully_refundable?).to be false
    end

    it "returns false if already partially refunded" do
      payment = build(:payment, :captured, refund_amount_cents: 5000)
      expect(payment.fully_refundable?).to be false
    end
  end

  describe "#remaining_refundable_amount" do
    it "returns full amount when no refunds" do
      payment = build(:payment, amount_cents: 10000, refund_amount_cents: nil)
      expect(payment.remaining_refundable_amount).to eq(10000)
    end

    it "returns difference when partially refunded" do
      payment = build(:payment, amount_cents: 10000, refund_amount_cents: 3000)
      expect(payment.remaining_refundable_amount).to eq(7000)
    end
  end

  describe "#capturable?" do
    it "returns true for authorized payments" do
      expect(build(:payment, :authorized).capturable?).to be true
    end

    it "returns false for other statuses" do
      expect(build(:payment, :captured).capturable?).to be false
      expect(build(:payment, status: :pending).capturable?).to be false
    end
  end

  describe "#refundable?" do
    it "returns true for captured payment with remaining amount" do
      payment = build(:payment, :captured, refund_amount_cents: 0)
      expect(payment.refundable?).to be true
    end

    it "returns false for fully refunded payment" do
      payment = build(:payment, :captured, amount_cents: 10000, refund_amount_cents: 10000)
      expect(payment.refundable?).to be false
    end

    it "returns false for pending payment" do
      expect(build(:payment, status: :pending).refundable?).to be false
    end
  end
end
