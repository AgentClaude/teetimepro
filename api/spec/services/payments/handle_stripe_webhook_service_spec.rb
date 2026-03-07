require "rails_helper"

RSpec.describe Payments::HandleStripeWebhookService, type: :service do
  let(:stripe_event_id) { "evt_test_123" }
  let(:event_type) { "payment_intent.succeeded" }
  let(:payment_intent_id) { "pi_test_123" }
  let(:event_data) do
    {
      "id" => payment_intent_id,
      "object" => "payment_intent",
      "amount" => 2000,
      "currency" => "usd",
      "status" => "succeeded"
    }
  end

  describe "#call" do
    context "with valid parameters" do
      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "creates a StripeEvent record" do
        expect { subject }.to change(StripeEvent, :count).by(1)
        
        stripe_event = StripeEvent.last
        expect(stripe_event.stripe_event_id).to eq(stripe_event_id)
        expect(stripe_event.event_type).to eq(event_type)
        expect(stripe_event.payload).to eq(event_data)
        expect(stripe_event).to be_processed
      end

      it "returns success" do
        expect(subject).to be_success
      end
    end

    context "when event already processed" do
      before { create(:stripe_event, :processed, stripe_event_id: stripe_event_id) }

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "does not create a new record" do
        expect { subject }.not_to change(StripeEvent, :count)
      end

      it "returns success with appropriate message" do
        result = subject
        expect(result).to be_success
        expect(result.message).to eq("Event already processed")
      end
    end

    context "with invalid parameters" do
      subject { described_class.call(stripe_event_id: nil, event_type: event_type, event_data: event_data) }

      it "returns failure" do
        expect(subject).to be_failure
        expect(subject.errors).to include("Stripe event can't be blank")
      end
    end

    describe "payment_intent.succeeded event" do
      let(:booking) { create(:booking) }
      let(:payment) { create(:payment, :pending, booking: booking, stripe_payment_intent_id: payment_intent_id) }

      before { payment } # Create the payment

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "marks payment as completed" do
        subject
        expect(payment.reload).to be_completed
      end

      it "does not change booking status since booking is already confirmed" do
        # The booking is already in confirmed status by default
        initial_status = booking.status
        subject
        expect(booking.reload.status).to eq(initial_status)
      end

      context "when payment does not exist" do
        let(:payment_intent_id) { "pi_nonexistent" }

        it "still processes successfully" do
          result = subject
          expect(result).to be_success
        end
      end
    end

    describe "payment_intent.payment_failed event" do
      let(:event_type) { "payment_intent.payment_failed" }
      let(:payment) { create(:payment, :pending, stripe_payment_intent_id: payment_intent_id) }

      before { payment } # Create the payment

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "marks payment as failed" do
        subject
        expect(payment.reload).to be_failed
      end
    end

    describe "charge.refunded event" do
      let(:event_type) { "charge.refunded" }
      let(:charge_data) do
        {
          "data" => {
            "object" => {
              "id" => "ch_test_123",
              "object" => "charge",
              "amount" => 2000,
              "amount_refunded" => 2000,
              "payment_intent" => payment_intent_id
            }
          }
        }
      end
      let(:event_data) { charge_data }
      let(:payment) { create(:payment, :completed, stripe_payment_intent_id: payment_intent_id, amount_cents: 2000) }

      before { payment } # Create the payment

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      context "when fully refunded" do
        it "marks payment as refunded" do
          subject
          expect(payment.reload).to be_refunded
          expect(payment.refund_amount_cents).to eq(2000)
        end
      end

      context "when partially refunded" do
        let(:charge_data) do
          {
            "data" => {
              "object" => {
                "id" => "ch_test_123",
                "object" => "charge",
                "amount" => 2000,
                "amount_refunded" => 1000,
                "payment_intent" => payment_intent_id
              }
            }
          }
        end

        it "marks payment as partially refunded" do
          subject
          expect(payment.reload).to be_partially_refunded
          expect(payment.refund_amount_cents).to eq(1000)
        end
      end
    end

    describe "charge.dispute.created event" do
      let(:event_type) { "charge.dispute.created" }
      let(:event_data) do
        {
          "data" => {
            "object" => {
              "id" => "dp_test_123",
              "object" => "dispute",
              "amount" => 2000,
              "charge" => "ch_test_123"
            }
          }
        }
      end

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "processes successfully and logs dispute" do
        expect(Rails.logger).to receive(:warn).with(/Dispute created for charge/)
        result = subject
        expect(result).to be_success
      end
    end

    describe "unhandled event type" do
      let(:event_type) { "customer.created" }

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "processes successfully and marks as processed" do
        expect(Rails.logger).to receive(:info).with("Unhandled Stripe webhook event type: customer.created")
        result = subject
        expect(result).to be_success
        expect(result.message).to eq("Event type not handled but marked as processed")
      end
    end

    describe "when processing fails" do
      let(:event_type) { "payment_intent.succeeded" }

      before do
        allow_any_instance_of(described_class).to receive(:handle_payment_succeeded).and_raise(StandardError, "Test error")
      end

      subject { described_class.call(stripe_event_id: stripe_event_id, event_type: event_type, event_data: event_data) }

      it "marks event as failed" do
        subject
        stripe_event = StripeEvent.find_by(stripe_event_id: stripe_event_id)
        expect(stripe_event).to be_failed
        expect(stripe_event.error_message).to eq("Test error")
      end

      it "returns failure" do
        result = subject
        expect(result).to be_failure
        expect(result.errors).to include("Failed to process webhook: Test error")
      end
    end
  end
end