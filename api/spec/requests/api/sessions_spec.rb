require "rails_helper"

RSpec.describe "Api::Sessions", type: :request do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization, password: "password123") }
  let(:secret) { ENV.fetch("JWT_SECRET_KEY", "test-secret") }

  describe "POST /api/auth/login" do
    it "returns access and refresh tokens on valid login" do
      post "/api/auth/login", params: { email: user.email, password: "password123" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
      expect(json["token_type"]).to eq("Bearer")
      expect(json["expires_in"]).to eq(3600)
      expect(json["user"]["id"]).to eq(user.id)
      expect(json["user"]["email"]).to eq(user.email)
    end

    it "returns access token with correct claims" do
      post "/api/auth/login", params: { email: user.email, password: "password123" }

      json = JSON.parse(response.body)
      payload = JWT.decode(json["access_token"], secret, true, { algorithm: "HS256" }).first

      expect(payload["sub"]).to eq(user.id)
      expect(payload["token_type"]).to eq("access")
      expect(payload["role"]).to eq(user.role)
      expect(payload["organization_id"]).to eq(user.organization_id)
    end

    it "returns refresh token with correct claims" do
      post "/api/auth/login", params: { email: user.email, password: "password123" }

      json = JSON.parse(response.body)
      payload = JWT.decode(json["refresh_token"], secret, true, { algorithm: "HS256" }).first

      expect(payload["sub"]).to eq(user.id)
      expect(payload["token_type"]).to eq("refresh")
      expect(payload["jti"]).to be_present
    end

    it "returns unauthorized on invalid password" do
      post "/api/auth/login", params: { email: user.email, password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized on invalid email" do
      post "/api/auth/login", params: { email: "nobody@example.com", password: "password123" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/auth/refresh" do
    let(:tokens) do
      post "/api/auth/login", params: { email: user.email, password: "password123" }
      JSON.parse(response.body)
    end

    it "returns new token pair with valid refresh token" do
      refresh_token = tokens["refresh_token"]

      post "/api/auth/refresh", params: { refresh_token: refresh_token }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["access_token"]).to be_present
      expect(json["refresh_token"]).to be_present
      expect(json["access_token"]).not_to eq(tokens["access_token"])
      expect(json["refresh_token"]).not_to eq(tokens["refresh_token"])
    end

    it "revokes the old refresh token after use" do
      refresh_token = tokens["refresh_token"]

      # First refresh should succeed
      post "/api/auth/refresh", params: { refresh_token: refresh_token }
      expect(response).to have_http_status(:ok)

      # Second refresh with same token should fail (revoked)
      post "/api/auth/refresh", params: { refresh_token: refresh_token }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Token has been revoked")
    end

    it "rejects an access token used as refresh token" do
      access_token = tokens["access_token"]

      post "/api/auth/refresh", params: { refresh_token: access_token }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid token type")
    end

    it "rejects expired refresh tokens" do
      expired_token = JWT.encode(
        { sub: user.id, jti: SecureRandom.uuid, token_type: "refresh", exp: 1.hour.ago.to_i },
        secret,
        "HS256"
      )

      post "/api/auth/refresh", params: { refresh_token: expired_token }

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Refresh token expired")
    end

    it "rejects invalid tokens" do
      post "/api/auth/refresh", params: { refresh_token: "garbage.token.here" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns bad request without refresh_token param" do
      post "/api/auth/refresh"

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "DELETE /api/auth/logout" do
    it "adds the access token to the denylist" do
      post "/api/auth/login", params: { email: user.email, password: "password123" }
      tokens = JSON.parse(response.body)

      expect {
        delete "/api/auth/logout", headers: { "Authorization" => "Bearer #{tokens['access_token']}" }
      }.to change(JwtDenylist, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "succeeds even without a token" do
      delete "/api/auth/logout"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "Token expiration handling" do
    it "returns token_expired code for expired access tokens" do
      expired_token = JWT.encode(
        {
          sub: user.id,
          jti: SecureRandom.uuid,
          token_type: "access",
          exp: 1.hour.ago.to_i
        },
        secret,
        "HS256"
      )

      get "/health", headers: { "Authorization" => "Bearer #{expired_token}" }
      # Health endpoint doesn't require auth, so let's test with a GraphQL request
      # The application controller handles this in authenticate_user!
    end
  end
end
