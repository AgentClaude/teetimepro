require "rails_helper"

RSpec.describe "Stripe Webhooks API", type: :request do
  let(:webhook_secret) { "whsec_test_secret" }
  let(:stripe_event_id) { "evt_test_123" }
  let(:payload) do
    {
      id: stripe_event_id,
      type: "payment_intent.succeeded",
      data: {
        object: {
          id: "pi_test_123",
          object: "payment_intent",
          amount: 2000,
          currency: "usd",
          status: "succeeded"
        }
      },
      created: Time.current.to_i
    }.to_json
  end

  before do
    ENV["STRIPE_WEBHOOK_SECRET"] = webhook_secret
  end

  after do
    ENV.delete("STRIPE_WEBHOOK_SECRET")
  end

  describe "POST /api/v1/stripe/webhooks" do
    let(:signature) { generate_stripe_signature(payload, webhook_secret) }
    let(:headers) do
      {
        "Content-Type" => "application/json",
        "Stripe-Signature" => signature
      }
    end

    before do
      allow(ProcessStripeWebhookJob).to receive(:perform_later)
    end

    context "with valid signature" do
      let(:mock_event) do
        double('Stripe::Event', 
          id: stripe_event_id, 
          type: 'payment_intent.succeeded', 
          data: double(to_h: { 'id' => 'pi_test_123' })
        )
      end

      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(mock_event)
      end

      it "returns 200 OK" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq({ "received" => true })
      end

      it "enqueues ProcessStripeWebhookJob" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(ProcessStripeWebhookJob).to have_received(:perform_later).with(
          stripe_event_id,
          "payment_intent.succeeded",
          hash_including("id" => "pi_test_123")
        )
      end

      it "does not require API key authentication" do
        # No Authorization header provided
        post "/api/v1/stripe/webhooks", params: payload, headers: headers.except("Authorization")

        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid signature" do
      let(:signature) { "invalid_signature" }

      before do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(Stripe::SignatureVerificationError.new("Invalid signature", nil))
      end

      it "returns 401 Unauthorized" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to eq({ "error" => "Invalid signature" })
      end

      it "does not enqueue job" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(ProcessStripeWebhookJob).not_to have_received(:perform_later)
      end
    end

    context "without Stripe signature header" do
      let(:headers) do
        {
          "Content-Type" => "application/json"
        }
      end

      before do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(Stripe::SignatureVerificationError.new("No signature", nil))
      end

      it "returns 401 Unauthorized" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response).to eq({ "error" => "Invalid signature" })
      end
    end

    context "when webhook secret is not configured" do
      before do
        ENV.delete("STRIPE_WEBHOOK_SECRET")
      end

      it "returns 500 Internal Server Error" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response).to eq({ "error" => "Webhook secret not configured" })
      end
    end

    context "when unexpected error occurs" do
      let(:mock_event) do
        double('Stripe::Event', 
          id: stripe_event_id, 
          type: 'payment_intent.succeeded', 
          data: double(to_h: { 'id' => 'pi_test_123' })
        )
      end

      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(mock_event)
        allow(ProcessStripeWebhookJob).to receive(:perform_later).and_raise(StandardError, "Unexpected error")
      end

      it "returns 500 Internal Server Error" do
        post "/api/v1/stripe/webhooks", params: payload, headers: headers

        expect(response).to have_http_status(:internal_server_error)
        expect(json_response).to eq({ "error" => "Internal server error" })
      end
    end
  end

  private

  def generate_stripe_signature(payload, secret)
    timestamp = Time.current.to_i
    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest("sha256", secret, signed_payload)
    "t=#{timestamp},v1=#{signature}"
  end

  def json_response
    JSON.parse(response.body)
  end
end