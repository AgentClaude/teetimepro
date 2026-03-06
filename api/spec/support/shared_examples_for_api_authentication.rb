RSpec.shared_examples "API authentication" do
  context "without API key" do
    before { headers.delete("Authorization") }

    it "returns 401 unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]["code"]).to eq("unauthorized")
      expect(json_response["error"]["message"]).to eq("API key required")
    end
  end

  context "with invalid API key" do
    before { headers["Authorization"] = "Bearer tp_invalid_key_long_enough" }

    it "returns 401 unauthorized" do
      make_request
      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]["code"]).to eq("unauthorized")
    end
  end

  context "with inactive API key" do
    before do
      api_key.update!(active: false)
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
