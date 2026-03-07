require "rails_helper"

RSpec.describe Calendars::GoogleAuthService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:authorization_code) { "auth_code_123" }

  before do
    # Mock credentials
    allow(Rails.application.credentials).to receive(:google).and_return(
      OpenStruct.new(
        client_id: "mock_client_id",
        client_secret: "mock_client_secret"
      )
    )
  end

  describe ".call" do
    context "with valid credentials and authorization code" do
      before do
        # Mock the token exchange request
        token_response = {
          access_token: "access_token_123",
          refresh_token: "refresh_token_123",
          expires_in: 3600
        }

        stub_request(:post, "https://oauth2.googleapis.com/token")
          .with(
            body: hash_including({
              code: authorization_code,
              client_id: "mock_client_id",
              client_secret: "mock_client_secret",
              redirect_uri: "https://app.teetimespro.com/auth/google/callback",
              grant_type: "authorization_code"
            })
          )
          .to_return(
            status: 200,
            body: token_response.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        # Mock the Google Calendar API call
        calendar_list_response = {
          items: [
            {
              id: "primary",
              summary: "Personal Calendar",
              primary: true
            }
          ]
        }

        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:list_calendar_lists)
          .and_return(OpenStruct.new(calendar_list_response))
      end

      it "creates calendar connection successfully" do
        result = described_class.call(
          user: user,
          authorization_code: authorization_code
        )

        expect(result).to be_success
        expect(result.connection).to be_a(CalendarConnection)
        expect(result.connection.provider).to eq("google")
        expect(result.connection.enabled).to be true
        expect(result.connection.access_token).to be_present
        expect(result.connection.refresh_token).to eq("refresh_token_123")
        expect(result.connection.calendar_id).to eq("primary")
        expect(result.connection.calendar_name).to eq("Personal Calendar")
      end

      it "updates existing connection if present" do
        existing_connection = create(:calendar_connection, user: user, provider: "google", enabled: false)

        result = described_class.call(
          user: user,
          authorization_code: authorization_code
        )

        expect(result).to be_success
        expect(CalendarConnection.count).to eq(1)
        
        existing_connection.reload
        expect(existing_connection.enabled).to be true
        expect(existing_connection.access_token).to be_present
      end
    end

    context "with invalid authorization code" do
      before do
        stub_request(:post, "https://oauth2.googleapis.com/token")
          .to_return(
            status: 400,
            body: { error: "invalid_grant" }.to_json,
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "returns failure with error message" do
        result = described_class.call(
          user: user,
          authorization_code: "invalid_code"
        )

        expect(result).to be_failure
        expect(result.errors).to include(/Google Calendar authorization failed/)
      end
    end

    context "with missing credentials" do
      before do
        allow(Rails.application.credentials).to receive(:google).and_return(nil)
      end

      it "returns failure for missing credentials" do
        result = described_class.call(
          user: user,
          authorization_code: authorization_code
        )

        expect(result).to be_failure
        expect(result.errors).to include("Google credentials not configured")
      end
    end

    context "with Google API error" do
      before do
        # Mock successful token exchange
        stub_request(:post, "https://oauth2.googleapis.com/token")
          .to_return(
            status: 200,
            body: {
              access_token: "access_token_123",
              refresh_token: "refresh_token_123",
              expires_in: 3600
            }.to_json,
            headers: { "Content-Type" => "application/json" }
          )

        # Mock Google Calendar API failure
        allow_any_instance_of(Google::Apis::CalendarV3::CalendarService)
          .to receive(:list_calendar_lists)
          .and_raise(Google::Apis::Error.new("API Error"))
      end

      it "returns failure with API error" do
        result = described_class.call(
          user: user,
          authorization_code: authorization_code
        )

        expect(result).to be_failure
        expect(result.errors).to include(/Google Calendar authorization failed/)
      end
    end

    context "with missing parameters" do
      it "fails without user" do
        result = described_class.call(
          user: nil,
          authorization_code: authorization_code
        )

        expect(result).to be_failure
        expect(result.errors).to include("User can't be blank")
      end

      it "fails without authorization code" do
        result = described_class.call(
          user: user,
          authorization_code: nil
        )

        expect(result).to be_failure
        expect(result.errors).to include("Authorization code can't be blank")
      end
    end
  end

  describe ".authorization_url" do
    it "generates correct authorization URL" do
      url = described_class.authorization_url("state123")

      expect(url).to include("accounts.google.com/o/oauth2/auth")
      expect(url).to include("client_id=mock_client_id")
      expect(url).to include("redirect_uri=#{CGI.escape('https://app.teetimespro.com/auth/google/callback')}")
      expect(url).to include("scope=#{CGI.escape('https://www.googleapis.com/auth/calendar')}")
      expect(url).to include("state=state123")
      expect(url).to include("access_type=offline")
      expect(url).to include("prompt=consent")
    end

    it "generates URL without state parameter when not provided" do
      url = described_class.authorization_url

      expect(url).to include("accounts.google.com/o/oauth2/auth")
      expect(url).not_to include("state=")
    end
  end
end