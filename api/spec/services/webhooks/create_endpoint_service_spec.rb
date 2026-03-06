require 'rails_helper'

RSpec.describe Webhooks::CreateEndpointService, type: :service do
  let(:organization) { create(:organization) }
  let(:valid_params) do
    {
      organization: organization,
      url: "https://example.com/webhook",
      events: ["booking.created", "payment.completed"],
      description: "Test webhook"
    }
  end

  describe "#call" do
    context "with valid parameters" do
      it "creates a webhook endpoint successfully" do
        result = described_class.call(valid_params)
        
        expect(result).to be_success
        expect(result.webhook_endpoint).to be_a(WebhookEndpoint)
        expect(result.webhook_endpoint.organization).to eq(organization)
        expect(result.webhook_endpoint.url).to eq("https://example.com/webhook")
        expect(result.webhook_endpoint.events).to eq(["booking.created", "payment.completed"])
        expect(result.webhook_endpoint.description).to eq("Test webhook")
        expect(result.webhook_endpoint.secret).to be_present
        expect(result.webhook_endpoint).to be_active
      end

      it "persists the webhook endpoint to the database" do
        expect {
          described_class.call(valid_params)
        }.to change(WebhookEndpoint, :count).by(1)
      end

      it "generates a secret if not provided" do
        result = described_class.call(valid_params)
        
        expect(result.webhook_endpoint.secret).to be_present
        expect(result.webhook_endpoint.secret.length).to be >= 64
      end

      it "uses provided secret if given" do
        custom_secret = SecureRandom.hex(32)
        params = valid_params.merge(secret: custom_secret)
        
        result = described_class.call(params)
        
        expect(result.webhook_endpoint.secret).to eq(custom_secret)
      end
    end

    context "with invalid parameters" do
      it "fails when organization is missing" do
        params = valid_params.except(:organization)
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Organization can't be blank")
      end

      it "fails when URL is missing" do
        params = valid_params.except(:url)
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Url can't be blank")
      end

      it "fails when events array is missing" do
        params = valid_params.except(:events)
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Events can't be blank")
      end

      it "fails when URL is not HTTPS" do
        params = valid_params.merge(url: "http://example.com/webhook")
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Url must be a valid HTTPS URL")
      end

      it "fails when events contain invalid event types" do
        params = valid_params.merge(events: ["invalid.event", "booking.created"])
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Events contains invalid event types: invalid.event")
      end

      it "fails when URL is not unique for the organization" do
        create(:webhook_endpoint, organization: organization, url: "https://example.com/webhook")
        
        result = described_class.call(valid_params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Url has already been taken")
      end

      it "doesn't create webhook endpoint when validation fails" do
        params = valid_params.merge(url: "http://example.com/webhook")
        
        expect {
          described_class.call(params)
        }.not_to change(WebhookEndpoint, :count)
      end
    end

    context "with edge cases" do
      it "handles empty events array" do
        params = valid_params.merge(events: [])
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Events can't be blank")
      end

      it "handles nil events" do
        params = valid_params.merge(events: nil)
        result = described_class.call(params)
        
        expect(result).to be_failure
        expect(result.errors).to include("Events can't be blank")
      end

      it "removes duplicate events" do
        params = valid_params.merge(events: ["booking.created", "booking.created", "payment.completed"])
        result = described_class.call(params)
        
        expect(result).to be_success
        expect(result.webhook_endpoint.events).to eq(["booking.created", "payment.completed"])
      end

      it "handles string events array" do
        params = valid_params.merge(events: "booking.created")
        result = described_class.call(params)
        
        expect(result).to be_success
        expect(result.webhook_endpoint.events).to eq(["booking.created"])
      end
    end
  end
end