require 'rails_helper'

RSpec.describe WebhookDeliveryJob, type: :job do
  let(:organization) { create(:organization) }
  let(:webhook_endpoint) { create(:webhook_endpoint, organization: organization) }
  let(:webhook_event) { create(:webhook_event, webhook_endpoint: webhook_endpoint) }

  describe "#perform" do
    context "with valid webhook event" do
      it "calls the delivery service" do
        mock_service = instance_double(Webhooks::DeliverWebhookService)
        allow(Webhooks::DeliverWebhookService).to receive(:call).and_return(mock_service)
        allow(mock_service).to receive(:success?).and_return(true)

        described_class.new.perform(webhook_event.id)

        expect(Webhooks::DeliverWebhookService).to have_received(:call).with(webhook_event: webhook_event)
      end

      it "logs successful delivery" do
        result = double("ServiceResult", success?: true)
        allow(Webhooks::DeliverWebhookService).to receive(:call).and_return(result)
        allow(Rails.logger).to receive(:info)

        described_class.new.perform(webhook_event.id)

        expect(Rails.logger).to have_received(:info).with(
          "Webhook delivery result: success for event #{webhook_event.id} to #{webhook_endpoint.url}"
        )
      end

      it "logs failed delivery with error messages" do
        result = double("ServiceResult", success?: false, error_messages: "Network timeout")
        allow(Webhooks::DeliverWebhookService).to receive(:call).and_return(result)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)

        described_class.new.perform(webhook_event.id)

        expect(Rails.logger).to have_received(:info).with(
          "Webhook delivery result: failure for event #{webhook_event.id} to #{webhook_endpoint.url}"
        )
        expect(Rails.logger).to have_received(:warn).with(
          "Webhook delivery failed: Network timeout"
        )
      end
    end

    context "with non-pending webhook event" do
      it "skips delivery for already delivered events" do
        delivered_event = create(:webhook_event, :delivered, webhook_endpoint: webhook_endpoint)

        expect(Webhooks::DeliverWebhookService).not_to receive(:call)

        described_class.new.perform(delivered_event.id)
      end

      it "skips delivery for failed events" do
        failed_event = create(:webhook_event, :failed, webhook_endpoint: webhook_endpoint)

        expect(Webhooks::DeliverWebhookService).not_to receive(:call)

        described_class.new.perform(failed_event.id)
      end
    end

    context "when webhook event is not found" do
      it "logs warning and continues gracefully" do
        allow(Rails.logger).to receive(:warn)

        expect {
          described_class.new.perform(99999)
        }.not_to raise_error

        expect(Rails.logger).to have_received(:warn).with(
          "WebhookEvent 99999 not found, skipping delivery"
        )
      end

      it "doesn't call the delivery service" do
        allow(Rails.logger).to receive(:warn)

        expect(Webhooks::DeliverWebhookService).not_to receive(:call)

        described_class.new.perform(99999)
      end
    end

    context "job configuration" do
      it "is configured to run in the webhooks queue" do
        expect(described_class.new.queue_name).to eq("webhooks")
      end

      it "has appropriate retry configuration" do
        # Job should have retry disabled since we handle retries in the service
        expect(described_class.retry_on_exceptions).to eq({ StandardError => { attempts: 1 } })
      end
    end

    context "error handling" do
      it "handles service errors gracefully" do
        allow(Webhooks::DeliverWebhookService).to receive(:call).and_raise(StandardError.new("Service error"))
        allow(Rails.logger).to receive(:warn)

        expect {
          described_class.new.perform(webhook_event.id)
        }.to raise_error(StandardError, "Service error")

        # Job should propagate the error for proper retry handling at the job level
      end

      it "handles database connection issues" do
        allow(WebhookEvent).to receive(:find).and_raise(ActiveRecord::ConnectionNotEstablished)

        expect {
          described_class.new.perform(webhook_event.id)
        }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end
    end

    context "integration with ActiveJob" do
      include ActiveJob::TestHelper

      it "enqueues the job properly" do
        expect {
          WebhookDeliveryJob.perform_later(webhook_event.id)
        }.to have_enqueued_job(WebhookDeliveryJob).with(webhook_event.id)
      end

      it "can be delayed for retry scenarios" do
        expect {
          WebhookDeliveryJob.set(wait: 1.hour).perform_later(webhook_event.id)
        }.to have_enqueued_job(WebhookDeliveryJob).with(webhook_event.id).at(1.hour.from_now)
      end

      it "executes the perform method when processed" do
        mock_service = double("ServiceResult", success?: true)
        allow(Webhooks::DeliverWebhookService).to receive(:call).and_return(mock_service)

        perform_enqueued_jobs do
          WebhookDeliveryJob.perform_later(webhook_event.id)
        end

        expect(Webhooks::DeliverWebhookService).to have_received(:call).with(webhook_event: webhook_event)
      end
    end

    context "concurrency considerations" do
      it "handles multiple jobs for the same event gracefully" do
        # Simulate the event being processed by another job
        allow(webhook_event).to receive(:pending?).and_return(false)
        allow(WebhookEvent).to receive(:find).and_return(webhook_event)

        expect(Webhooks::DeliverWebhookService).not_to receive(:call)

        described_class.new.perform(webhook_event.id)
      end

      it "reloads event state from database" do
        # This ensures we get the latest state even if another process modified it
        expect(WebhookEvent).to receive(:find).with(webhook_event.id).and_return(webhook_event)

        allow(webhook_event).to receive(:pending?).and_return(false)

        described_class.new.perform(webhook_event.id)
      end
    end
  end
end