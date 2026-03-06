RSpec.shared_examples "API authentication" do
  context "without API key" do
    before { headers.delete("Authorization") }

    it "returns 401 unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("API key required")
      expect(json_response["code"]).to eq("unauthorized")
    end
  end

  context "with invalid API key" do
    before { headers["Authorization"] = "Bearer tp_invalid_key" }

    it "returns 401 unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("Invalid API key")
    end
  end

  context "with inactive API key" do
    before do
      api_key.update!(active: false)
      headers["Authorization"] = "Bearer #{api_key.display_key}"
    end

    it "returns 401 unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_examples "API rate limiting" do |endpoint_path|
  it "tracks API key usage" do
    make_request
    expect(api_key.reload.last_used_at).to be_present
  end

  # Note: Rate limiting tests would require Redis and are complex to test
  # In a real implementation, you'd want integration tests for these
end

RSpec.shared_examples "API pagination" do
  it "includes pagination metadata" do
    make_request
    expect(response).to have_http_status(:ok)
    expect(json_response).to have_key("meta")
    expect(json_response["meta"]).to include(
      "current_page",
      "per_page",
      "total_pages",
      "total_count"
    )
  end

  context "with pagination parameters" do
    let(:params) { { page: 2, per_page: 5 } }

    it "respects pagination parameters" do
      make_request
      expect(json_response["meta"]["current_page"]).to eq(2)
      expect(json_response["meta"]["per_page"]).to eq(5)
    end
  end
end