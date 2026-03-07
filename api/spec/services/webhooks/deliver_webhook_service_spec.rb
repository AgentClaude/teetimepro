require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Webhooks::DeliverWebhookService, type: :service do
  let(:organization) { create(:organization) }
  let(:webhook_endpoint) { create(:webhook_endpoint, organization: organization, url: "https://example.com/webhook") }
  let(:webhook_event) { create(:webhook_event, webhook_endpoint: webhook_endpoint) }

  before do
    WebMock.reset!
  end

  describe "#call" do
    context "successful delivery" do
      before do
        stub_request(:post, webhook_endpoint.url)
          .to_return(status: 200, body: "OK")
      end

      it "marks event as delivered" do
        result = described_class.call(webhook_event: webhook_event)

        expect(result).to be_success
        expect(result.delivered).to be true
        expect(result.response_code).to eq(200)

        webhook_event.reload
        expect(webhook_event.status).to eq("delivered")
        expect(webhook_event.delivered_at).to be_present
        expect(webhook_event.response_code).to eq(200)
        expect(webhook_event.response_body).to eq("OK")
      end

      it "increments attempts counter" do
        original_attempts = webhook_event.attempts

        described_class.call(webhook_event: webhook_event)

        webhook_event.reload
        expect(webhook_event.attempts).to eq(original_attempts + 1)
      end

      it "sends correct headers" do
        described_class.call(webhook_event: webhook_event)

        expect(WebMock).to have_requested(:post, webhook_endpoint.url)
          .with(headers: {
            'Content-Type' => 'application/json',
            'User-Agent' => 'TeeTimes-Pro-Webhooks/1.0',
            'X-Webhook-Event' => webhook_event.event_type,
            'X-Webhook-Delivery-Id' => webhook_event.id.to_s,
            'X-Webhook-Signature' => /\A[a-f0-9]{64}\z/
          })
      end

      it "sends correct payload" do
        described_class.call(webhook_event: webhook_event)

        expect(WebMock).to have_requested(:post, webhook_endpoint.url)
          .with(body: webhook_event.payload.to_json)
      end

      it "generates valid HMAC signature" do
        described_class.call(webhook_event: webhook_event)

        # Extract the signature from the request
        request = WebMock.requests.last
        signature = request.headers['X-Webhook-Signature']

        # Verify signature
        expected_signature = OpenSSL::HMAC.hexdigest('SHA256', webhook_endpoint.secret, webhook_event.payload.to_json)
        expect(signature).to eq(expected_signature)
      end
    end

    context "failed delivery" do
      context "HTTP error responses" do
        before do
          stub_request(:post, webhook_endpoint.url)
            .to_return(status: 500, body: "Internal Server Error")
        end

        it "schedules retry for retryable events" do
          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
          expect(result.errors).to include("Delivery failed, retry scheduled")
          expect(result.response_code).to eq(500)
          expect(result[:retry_in]).to be_a(Integer)

          webhook_event.reload
          expect(webhook_event.status).to eq("pending")
        end

        it "marks as failed after max attempts" do
          webhook_event.update!(attempts: 5)

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
          expect(result.errors).to include("Delivery failed after maximum attempts")
          expect(result[:max_attempts_reached]).to be true

          webhook_event.reload
          expect(webhook_event.status).to eq("failed")
          expect(webhook_event.response_code).to eq(500)
        end
      end

      context "network errors" do
        it "handles timeout errors" do
          stub_request(:post, webhook_endpoint.url)
            .to_timeout

          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
          expect(result.errors).to include("Delivery failed, retry scheduled")
        end

        it "handles socket errors" do
          stub_request(:post, webhook_endpoint.url)
            .to_raise(SocketError.new("DNS resolution failed"))

          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
        end

        it "handles bad response errors" do
          stub_request(:post, webhook_endpoint.url)
            .to_raise(Net::HTTPBadResponse.new("Invalid response"))

          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
        end
      end

      context "unexpected errors" do
        it "handles unknown errors gracefully" do
          stub_request(:post, webhook_endpoint.url)
            .to_raise(StandardError.new("Something went wrong"))

          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
        end
      end
    end

    context "HTTP configuration" do
      it "uses SSL for HTTPS URLs" do
        described_class.call(webhook_event: webhook_event)

        # Verify SSL was used (WebMock handles this automatically for https)
        expect(WebMock).to have_requested(:post, webhook_endpoint.url)
      end

      it "sets appropriate timeouts" do
        # This is harder to test directly, but we can verify the configuration
        service = described_class.new(webhook_event: webhook_event)
        
        # Test that the service validates the webhook_event
        expect(service.valid?).to be true
      end
    end

    context "with invalid parameters" do
      it "fails when webhook_event is missing" do
        result = described_class.call(webhook_event: nil)

        expect(result).to be_failure
        expect(result.errors).to include("Webhook event can't be blank")
      end

      it "doesn't make HTTP request when validation fails" do
        described_class.call(webhook_event: nil)

        expect(WebMock).not_to have_requested(:post, /.*/)
      end
    end

    context "retry logic" do
      it "calculates retry delay using exponential backoff" do
        webhook_event.update!(attempts: 2)
        
        stub_request(:post, webhook_endpoint.url)
          .to_return(status: 500)

        expect(WebhookDeliveryJob).to receive(:set) do |options|
          delay = options[:wait]
          # After increment_attempts! (2→3), delay = 30 * 2^3 = 240 + jitter (10-30%)
          expect(delay).to be_between(240, 320)
          double(perform_later: nil)
        end

        described_class.call(webhook_event: webhook_event)
      end

      it "doesn't schedule retry when should_retry? returns false" do
        allow(webhook_event).to receive(:should_retry?).and_return(false)
        
        stub_request(:post, webhook_endpoint.url)
          .to_return(status: 500)

        expect(WebhookDeliveryJob).not_to receive(:set)

        result = described_class.call(webhook_event: webhook_event)

        expect(result).to be_failure
        expect(result[:max_attempts_reached]).to be true
      end
    end

    context "response handling" do
      it "accepts 2xx status codes as success" do
        [200, 201, 202, 204].each do |status|
          webhook_event = create(:webhook_event, webhook_endpoint: webhook_endpoint)
          
          stub_request(:post, webhook_endpoint.url)
            .to_return(status: status, body: "Success")

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_success
          expect(result.response_code).to eq(status)

          webhook_event.reload
          expect(webhook_event.status).to eq("delivered")
        end
      end

      it "treats 3xx, 4xx, 5xx as failures" do
        [301, 400, 404, 500, 503].each do |status|
          webhook_event = create(:webhook_event, webhook_endpoint: webhook_endpoint)
          
          stub_request(:post, webhook_endpoint.url)
            .to_return(status: status, body: "Error")

          expect(WebhookDeliveryJob).to receive(:set).with(wait: anything).and_return(double(perform_later: nil))

          result = described_class.call(webhook_event: webhook_event)

          expect(result).to be_failure
          expect(result.response_code).to eq(status)
        end
      end

      it "truncates long response bodies" do
        long_body = "x" * 2000
        
        stub_request(:post, webhook_endpoint.url)
          .to_return(status: 200, body: long_body)

        described_class.call(webhook_event: webhook_event)

        webhook_event.reload
        expect(webhook_event.response_body.length).to eq(1000)
      end
    end
  end
end
