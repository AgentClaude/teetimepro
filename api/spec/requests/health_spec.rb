require "rails_helper"

RSpec.describe "Health Check", type: :request do
  describe "GET /health" do
    it "returns 200 with status ok" do
      get "/health"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["status"]).to eq("ok")
      expect(body).to have_key("timestamp")
      expect(body["database"]).to eq("ok")
    end
  end
end
