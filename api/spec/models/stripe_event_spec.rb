require "rails_helper"

RSpec.describe StripeEvent, type: :model do
  describe "validations" do
    it "validates presence of required fields" do
      event = StripeEvent.new
      expect(event).not_to be_valid
      expect(event.errors[:stripe_event_id]).to include("can't be blank")
      expect(event.errors[:event_type]).to include("can't be blank")
      expect(event.errors[:payload]).to include("can't be blank")
    end

    it "validates uniqueness of stripe_event_id" do
      StripeEvent.create!(
        stripe_event_id: "evt_123",
        event_type: "payment_intent.succeeded",
        payload: { test: true }
      )

      duplicate = StripeEvent.new(
        stripe_event_id: "evt_123",
        event_type: "payment_intent.succeeded",
        payload: { test: true }
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:stripe_event_id]).to include("has already been taken")
    end
  end

  describe "enums" do
    it "defines status enum correctly" do
      expect(StripeEvent.statuses).to eq({
        "pending" => 0,
        "processed" => 1,
        "failed" => 2
      })
    end
  end

  describe "scopes" do
    let!(:payment_event) { create(:stripe_event, event_type: "payment_intent.succeeded", stripe_event_id: "evt_payment") }
    let!(:refund_event) { create(:stripe_event, event_type: "charge.refunded", stripe_event_id: "evt_refund") }
    let!(:processed_event) { create(:stripe_event, :processed, event_type: "payment_intent.payment_failed", stripe_event_id: "evt_processed") }
    let!(:pending_event) { create(:stripe_event, :pending, event_type: "charge.dispute.created", stripe_event_id: "evt_pending") }

    describe ".by_event_type" do
      it "filters by event type" do
        expect(StripeEvent.by_event_type("payment_intent.succeeded")).to contain_exactly(payment_event)
        expect(StripeEvent.by_event_type("charge.refunded")).to contain_exactly(refund_event)
      end
    end

    describe ".unprocessed" do
      it "returns non-processed events" do
        unprocessed = StripeEvent.unprocessed
        expect(unprocessed).to include(pending_event)
        expect(unprocessed).not_to include(processed_event)
      end
    end
  end

  describe ".already_processed?" do
    it "returns true for processed events" do
      event = create(:stripe_event, :processed, stripe_event_id: "evt_processed")
      expect(StripeEvent.already_processed?("evt_processed")).to be true
    end

    it "returns false for non-processed events" do
      create(:stripe_event, :pending, stripe_event_id: "evt_pending")
      expect(StripeEvent.already_processed?("evt_pending")).to be false
    end

    it "returns false for non-existent events" do
      expect(StripeEvent.already_processed?("evt_nonexistent")).to be false
    end
  end

  describe "#mark_processed!" do
    let(:event) { create(:stripe_event, :pending) }

    it "marks event as processed with timestamp" do
      freeze_time do
        event.mark_processed!
        expect(event.reload).to be_processed
        expect(event.processed_at).to eq(Time.current)
        expect(event.error_message).to be_nil
      end
    end
  end

  describe "#mark_failed!" do
    let(:event) { create(:stripe_event, :pending) }
    let(:error) { StandardError.new("Test error") }

    it "marks event as failed with error message" do
      event.mark_failed!(error)
      expect(event.reload).to be_failed
      expect(event.error_message).to eq("Test error")
    end
  end
end