require "rails_helper"

RSpec.describe ProcessStripeWebhookJob, type: :job do
  let(:stripe_event_id) { "evt_test_123" }
  let(:event_type) { "payment_intent.succeeded" }
  let(:event_data) do
    {
      "id" => "pi_test_123",
      "object" => "payment_intent",
      "amount" => 2000,
      "currency" => "usd",
      "status" => "succeeded"
    }
  end

  describe "#perform" do
    context "when service call is successful" do
      let(:successful_result) { instance_double(ServiceResult, success?: true, failure?: false) }

      before do
        allow(Payments::HandleStripeWebhookService).to receive(:call).and_return(successful_result)
      end

      it "calls the HandleStripeWebhookService with correct parameters" do
        subject.perform(stripe_event_id, event_type, event_data)

        expect(Payments::HandleStripeWebhookService).to have_received(:call).with(
          stripe_event_id: stripe_event_id,
          event_type: event_type,
          event_data: event_data
        )
      end

      it "logs successful processing" do
        expect(Rails.logger).to receive(:info).with("Processing Stripe webhook: #{event_type} (#{stripe_event_id})")
        expect(Rails.logger).to receive(:info).with("Successfully processed Stripe webhook: #{stripe_event_id}")

        subject.perform(stripe_event_id, event_type, event_data)
      end
    end

    context "when service call fails" do
      let(:failed_result) do
        instance_double(ServiceResult, 
          success?: false, 
          failure?: true, 
          error_messages: "Payment not found"
        )
      end

      before do
        allow(Payments::HandleStripeWebhookService).to receive(:call).and_return(failed_result)
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:info).with("Processing Stripe webhook: #{event_type} (#{stripe_event_id})")
        expect(Rails.logger).to receive(:error).with("Stripe webhook processing failed: Payment not found")

        expect {
          subject.perform(stripe_event_id, event_type, event_data)
        }.to raise_error(StandardError, "Webhook processing failed: Payment not found")
      end

      it "raises an error to trigger job retry" do
        expect {
          subject.perform(stripe_event_id, event_type, event_data)
        }.to raise_error(StandardError, "Webhook processing failed: Payment not found")
      end
    end

    context "job configuration" do
      it "uses the webhooks queue" do
        expect(described_class.queue_name).to eq("webhooks")
      end

      it "inherits from ApplicationJob" do
        expect(described_class.superclass).to eq(ApplicationJob)
      end
    end
  end
end