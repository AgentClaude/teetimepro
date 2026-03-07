require 'rails_helper'

RSpec.describe "/api/v1/webhooks", type: :request do
  let(:organization) { create(:organization) }
  let(:api_key) { create(:api_key, organization: organization) }
  let(:headers) { { "Authorization" => "Bearer #{api_key.key}" } }

  describe "GET /api/v1/webhooks" do
    let!(:webhook1) { create(:webhook_endpoint, organization: organization, created_at: 1.hour.ago) }
    let!(:webhook2) { create(:webhook_endpoint, organization: organization, created_at: 2.hours.ago) }
    let!(:other_org_webhook) { create(:webhook_endpoint) }

    it "returns webhook endpoints for the current organization" do
      get "/api/v1/webhooks", headers: headers

      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      expect(json["data"]).to be_an(Array)
      expect(json["data"].length).to eq(2)
      
      webhook_ids = json["data"].map { |w| w["id"] }
      expect(webhook_ids).to include(webhook1.id, webhook2.id)
      expect(webhook_ids).not_to include(other_org_webhook.id)
    end

    it "includes pagination metadata" do
      get "/api/v1/webhooks", headers: headers

      json = JSON.parse(response.body)
      expect(json["meta"]).to include(
        "current_page" => 1,
        "per_page" => 25,
        "total_count" => 2
      )
    end

    it "includes webhook endpoint data" do
      get "/api/v1/webhooks", headers: headers

      json = JSON.parse(response.body)
      webhook_data = json["data"].first

      expect(webhook_data).to include(
        "id",
        "url",
        "events",
        "active",
        "description",
        "success_rate",
        "created_at",
        "updated_at"
      )
    end

    it "requires authentication" do
      get "/api/v1/webhooks"

      expect(response).to have_http_status(:unauthorized)
    end

    context "pagination" do
      before do
        create_list(:webhook_endpoint, 30, organization: organization)
      end

      it "paginates results" do
        get "/api/v1/webhooks", params: { per_page: 10, page: 2 }, headers: headers

        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(10)
        expect(json["meta"]["current_page"]).to eq(2)
      end
    end
  end

  describe "GET /api/v1/webhooks/:id" do
    let!(:webhook_endpoint) { create(:webhook_endpoint, organization: organization) }
    let!(:recent_event1) { create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 1.hour.ago) }
    let!(:recent_event2) { create(:webhook_event, webhook_endpoint: webhook_endpoint, created_at: 2.hours.ago) }

    it "returns the webhook endpoint with recent events" do
      get "/api/v1/webhooks/#{webhook_endpoint.id}", headers: headers

      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body)
      webhook_data = json["data"]

      expect(webhook_data["id"]).to eq(webhook_endpoint.id)
      expect(webhook_data["recent_events"]).to be_an(Array)
      expect(webhook_data["recent_events"].length).to eq(2)
    end

    it "includes recent event details" do
      get "/api/v1/webhooks/#{webhook_endpoint.id}", headers: headers

      json = JSON.parse(response.body)
      event_data = json["data"]["recent_events"].first

      expect(event_data).to include(
        "id",
        "event_type",
        "status",
        "attempts",
        "response_code",
        "created_at"
      )
    end

    it "returns 404 for webhook not in organization" do
      other_webhook = create(:webhook_endpoint)

      get "/api/v1/webhooks/#{other_webhook.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for non-existent webhook" do
      get "/api/v1/webhooks/99999", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/webhooks" do
    let(:valid_params) do
      {
        webhook: {
          url: "https://example.com/webhook",
          events: ["booking.created", "payment.completed"],
          description: "Test webhook"
        }
      }
    end

    it "creates a new webhook endpoint" do
      expect {
        post "/api/v1/webhooks", params: valid_params, headers: headers
      }.to change(WebhookEndpoint, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      webhook_data = json["data"]

      expect(webhook_data["url"]).to eq("https://example.com/webhook")
      expect(webhook_data["events"]).to eq(["booking.created", "payment.completed"])
      expect(webhook_data["description"]).to eq("Test webhook")
    end

    it "assigns the webhook to the current organization" do
      post "/api/v1/webhooks", params: valid_params, headers: headers

      webhook = WebhookEndpoint.last
      expect(webhook.organization).to eq(organization)
    end

    it "generates a secret automatically" do
      post "/api/v1/webhooks", params: valid_params, headers: headers

      webhook = WebhookEndpoint.last
      expect(webhook.secret).to be_present
      expect(webhook.secret.length).to be >= 64
    end

    it "allows custom secret" do
      custom_secret = SecureRandom.hex(32)
      params = valid_params.deep_merge(webhook: { secret: custom_secret })

      post "/api/v1/webhooks", params: params, headers: headers

      webhook = WebhookEndpoint.last
      expect(webhook.secret).to eq(custom_secret)
    end

    context "with invalid parameters" do
      it "returns validation errors for missing URL" do
        params = valid_params.deep_merge(webhook: { url: nil })

        post "/api/v1/webhooks", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["error"]).to include("Url can't be blank")
      end

      it "returns validation errors for invalid URL" do
        params = valid_params.deep_merge(webhook: { url: "http://example.com" })

        post "/api/v1/webhooks", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["error"]).to include("Url must be a valid HTTPS URL")
      end

      it "returns validation errors for invalid events" do
        params = valid_params.deep_merge(webhook: { events: ["invalid.event"] })

        post "/api/v1/webhooks", params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json["error"]).to include("Events contains invalid event types")
      end
    end
  end

  describe "PATCH /api/v1/webhooks/:id" do
    let!(:webhook_endpoint) { create(:webhook_endpoint, organization: organization, url: "https://old.example.com") }

    let(:update_params) do
      {
        webhook: {
          url: "https://new.example.com/webhook",
          events: ["booking.created"],
          description: "Updated webhook",
          active: false
        }
      }
    end

    it "updates the webhook endpoint" do
      patch "/api/v1/webhooks/#{webhook_endpoint.id}", params: update_params, headers: headers

      expect(response).to have_http_status(:ok)

      webhook_endpoint.reload
      expect(webhook_endpoint.url).to eq("https://new.example.com/webhook")
      expect(webhook_endpoint.events).to eq(["booking.created"])
      expect(webhook_endpoint.description).to eq("Updated webhook")
      expect(webhook_endpoint.active).to be false
    end

    it "allows partial updates" do
      params = { webhook: { description: "New description only" } }

      patch "/api/v1/webhooks/#{webhook_endpoint.id}", params: params, headers: headers

      expect(response).to have_http_status(:ok)

      webhook_endpoint.reload
      expect(webhook_endpoint.description).to eq("New description only")
      expect(webhook_endpoint.url).to eq("https://old.example.com") # Unchanged
    end

    it "returns validation errors for invalid updates" do
      params = { webhook: { url: "http://invalid.com" } }

      patch "/api/v1/webhooks/#{webhook_endpoint.id}", params: params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for webhook not in organization" do
      other_webhook = create(:webhook_endpoint)

      patch "/api/v1/webhooks/#{other_webhook.id}", params: update_params, headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/webhooks/:id" do
    let!(:webhook_endpoint) { create(:webhook_endpoint, organization: organization) }

    it "deletes the webhook endpoint" do
      expect {
        delete "/api/v1/webhooks/#{webhook_endpoint.id}", headers: headers
      }.to change(WebhookEndpoint, :count).by(-1)

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Webhook endpoint deleted successfully")
    end

    it "deletes associated webhook events" do
      create(:webhook_event, webhook_endpoint: webhook_endpoint)

      expect {
        delete "/api/v1/webhooks/#{webhook_endpoint.id}", headers: headers
      }.to change(WebhookEvent, :count).by(-1)
    end

    it "returns 404 for webhook not in organization" do
      other_webhook = create(:webhook_endpoint)

      delete "/api/v1/webhooks/#{other_webhook.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/webhooks/:id/test" do
    let!(:webhook_endpoint) { create(:webhook_endpoint, organization: organization, events: ["booking.created"]) }

    it "sends a test webhook event" do
      allow(WebhookDeliveryJob).to receive(:perform_later)

      post "/api/v1/webhooks/#{webhook_endpoint.id}/test", headers: headers

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Test webhook sent successfully")
      expect(json["webhook_events"]).to be_an(Array)
      expect(json["webhook_events"].length).to eq(1)
    end

    it "creates a webhook event with test payload" do
      allow(WebhookDeliveryJob).to receive(:perform_later)

      expect {
        post "/api/v1/webhooks/#{webhook_endpoint.id}/test", headers: headers
      }.to change(WebhookEvent, :count).by(1)

      webhook_event = WebhookEvent.last
      expect(webhook_event.event_type).to eq("booking.created")
      expect(webhook_event.payload["test_data"]["message"]).to eq("This is a test webhook event")
    end

    it "enqueues delivery job for test event" do
      expect(WebhookDeliveryJob).to receive(:perform_later).once

      post "/api/v1/webhooks/#{webhook_endpoint.id}/test", headers: headers
    end

    it "returns 404 for webhook not in organization" do
      other_webhook = create(:webhook_endpoint)

      post "/api/v1/webhooks/#{other_webhook.id}/test", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "authentication and authorization" do
    it "requires valid API key" do
      get "/api/v1/webhooks", headers: { "Authorization" => "Bearer invalid_key" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "scopes to current organization" do
      other_org = create(:organization)
      other_api_key = create(:api_key, organization: other_org)
      other_headers = { "Authorization" => "Bearer #{other_api_key.key}" }

      webhook = create(:webhook_endpoint, organization: organization)

      get "/api/v1/webhooks/#{webhook.id}", headers: other_headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
