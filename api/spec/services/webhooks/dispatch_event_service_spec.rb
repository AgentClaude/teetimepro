require 'rails_helper'

RSpec.describe Webhooks::DispatchEventService, type: :service do
  let(:organization) { create(:organization) }
  let(:event_payload) do
    {
      id: 123,
      type: "booking",
      attributes: {
        confirmation_code: "ABC123",
        players_count: 2,
        total_cents: 8000
      },
      timestamp: Time.current.iso8601
    }
  end
  let(:valid_params) do
    {
      organization: organization,
      event_type: "booking.created",
      payload: event_payload
    }
  end

  describe "#call" do
    context "with valid parameters" do
      let!(:subscribed_endpoint1) { create(:webhook_endpoint, organization: organization, events: ["booking.created", "booking.cancelled"]) }
      let!(:subscribed_endpoint2) { create(:webhook_endpoint, organization: organization, events: ["booking.created", "payment.completed"]) }
      let!(:unsubscribed_endpoint) { create(:webhook_endpoint, organization: organization, events: ["payment.completed"]) }

      it "creates webhook events for subscribed endpoints" do
        allow(WebhookDeliveryJob).to receive(:perform_later)

        expect {
          described_class.call(valid_params)
        }.to change(WebhookEvent, :count).by(2)
      end

      it "enqueues delivery jobs for each webhook event" do
        expect(WebhookDeliveryJob).to receive(:perform_later).twice

        described_class.call(valid_params)
      end

      it "returns success with webhook events and count" do
        result = described_class.call(valid_params)

        expect(result).to be_success
        expect(result.webhook_events).to be_an(Array)
        expect(result.webhook_events.length).to eq(2)
        expect(result.endpoints_count).to eq(2)
      end

      it "creates webhook events with correct attributes" do
        result = described_class.call(valid_params)

        webhook_event = result.webhook_events.first
        expect(webhook_event.event_type).to eq("booking.created")
        expect(webhook_event.payload).to eq(event_payload)
        expect(webhook_event.status).to eq("pending")
        expect(webhook_event.attempts).to eq(0)
      end

      it "only creates events for active endpoints" do
        create(:webhook_endpoint, :inactive, organization: organization, events: ["booking.created"])

        result = described_class.call(valid_params)

        expect(result.endpoints_count).to eq(2) # Only the active ones
      end

      it "only creates events for endpoints in the same organization" do
        other_org = create(:organization)
        create(:webhook_endpoint, organization: other_org, events: ["booking.created"])

        result = described_class.call(valid_params)

        expect(result.endpoints_count).to eq(2) # Only for our organization
      end
    end

    context "with invalid parameters" do
      it "fails when organization is missing" do
        params = valid_params.except(:organization)
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.errors).to include("Organization can't be blank")
      end

      it "fails when event_type is missing" do
        params = valid_params.except(:event_type)
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.errors).to include("Event type can't be blank")
      end

      it "fails when payload is missing" do
        params = valid_params.except(:payload)
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.errors).to include("Payload can't be blank")
      end

      it "fails when event_type is invalid" do
        params = valid_params.merge(event_type: "invalid.event")
        result = described_class.call(params)

        expect(result).to be_failure
        expect(result.errors).to include("Invalid event type")
      end

      it "doesn't create webhook events when validation fails" do
        create(:webhook_endpoint, organization: organization, events: ["booking.created"])
        params = valid_params.merge(event_type: "invalid.event")

        expect {
          described_class.call(params)
        }.not_to change(WebhookEvent, :count)
      end

      it "doesn't enqueue jobs when validation fails" do
        expect(WebhookDeliveryJob).not_to receive(:perform_later)
        
        params = valid_params.merge(event_type: "invalid.event")
        described_class.call(params)
      end
    end

    context "when no endpoints are subscribed" do
      it "returns success with empty results" do
        # No endpoints subscribed to this event
        create(:webhook_endpoint, organization: organization, events: ["payment.completed"])

        result = described_class.call(valid_params)

        expect(result).to be_success
        expect(result.webhook_events).to eq([])
        expect(result.endpoints_count).to eq(0)
      end

      it "doesn't create any webhook events" do
        create(:webhook_endpoint, organization: organization, events: ["payment.completed"])

        expect {
          described_class.call(valid_params)
        }.not_to change(WebhookEvent, :count)
      end
    end

    context "with different event types" do
      let!(:booking_endpoint) { create(:webhook_endpoint, organization: organization, events: ["booking.created", "booking.cancelled"]) }
      let!(:payment_endpoint) { create(:webhook_endpoint, organization: organization, events: ["payment.completed"]) }
      let!(:all_events_endpoint) { create(:webhook_endpoint, :with_all_events, organization: organization) }

      it "dispatches to correct endpoints for booking events" do
        result = described_class.call(valid_params.merge(event_type: "booking.created"))

        expect(result.endpoints_count).to eq(2) # booking_endpoint + all_events_endpoint
      end

      it "dispatches to correct endpoints for payment events" do
        result = described_class.call(valid_params.merge(event_type: "payment.completed"))

        expect(result.endpoints_count).to eq(2) # payment_endpoint + all_events_endpoint
      end

      it "dispatches to all endpoints subscribed to all events" do
        WebhookEndpoint::AVAILABLE_EVENTS.each do |event_type|
          result = described_class.call(valid_params.merge(event_type: event_type))
          
          # all_events_endpoint should always be included
          endpoint_ids = result.webhook_events.map { |e| e.webhook_endpoint.id }
          expect(endpoint_ids).to include(all_events_endpoint.id)
        end
      end
    end

    context "when database errors occur" do
      it "handles ActiveRecord::RecordInvalid errors" do
        allow_any_instance_of(WebhookEvent).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(WebhookEvent.new))
        create(:webhook_endpoint, organization: organization, events: ["booking.created"])

        result = described_class.call(valid_params)

        expect(result).to be_failure
        expect(result.errors.first).to include("Validation failed")
      end
    end

    context "integration scenarios" do
      it "handles large payloads" do
        large_payload = { data: "x" * 10000, timestamp: Time.current.iso8601 }
        create(:webhook_endpoint, organization: organization, events: ["booking.created"])

        result = described_class.call(valid_params.merge(payload: large_payload))

        expect(result).to be_success
        webhook_event = result.webhook_events.first
        expect(webhook_event.payload).to eq(large_payload)
      end

      it "processes multiple endpoints efficiently" do
        # Create multiple endpoints
        10.times do
          create(:webhook_endpoint, organization: organization, events: ["booking.created"])
        end

        expect(WebhookDeliveryJob).to receive(:perform_later).exactly(10).times

        result = described_class.call(valid_params)

        expect(result).to be_success
        expect(result.endpoints_count).to eq(10)
      end
    end
  end
end