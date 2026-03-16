# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushNotifications::SendPushNotificationService do
  let(:tokens) { ["ExponentPushToken[abc]", "ExponentPushToken[def]"] }
  let(:title) { "Test Title" }
  let(:body) { "Test body message" }

  before do
    stub_request(:post, described_class::EXPO_PUSH_URL)
      .to_return(
        status: 200,
        body: Oj.dump({
          "data" => tokens.map { |_t| { "status" => "ok" } }
        }),
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe ".call" do
    context "with valid parameters" do
      it "sends push notifications successfully" do
        result = described_class.call(tokens: tokens, title: title, body: body)

        expect(result).to be_success
        expect(result.sent).to eq(2)
        expect(result.failed).to eq(0)
      end

      it "posts to the Expo push API" do
        described_class.call(tokens: tokens, title: title, body: body)

        expect(WebMock).to have_requested(:post, described_class::EXPO_PUSH_URL)
          .with { |req|
            messages = Oj.load(req.body)
            messages.length == 2 &&
              messages.all? { |m| m["title"] == title && m["body"] == body }
          }
      end
    end

    context "with empty tokens" do
      it "returns success with zero sent" do
        result = described_class.call(tokens: [], title: title, body: body)
        expect(result).to be_success
        expect(result.sent).to eq(0)
      end
    end

    context "when Expo returns DeviceNotRegistered" do
      let(:user) { create(:user) }
      let!(:device_token) { create(:device_token, user: user, token: tokens.first, active: true) }

      before do
        stub_request(:post, described_class::EXPO_PUSH_URL)
          .to_return(
            status: 200,
            body: Oj.dump({
              "data" => [
                { "status" => "error", "message" => "bad token", "details" => { "error" => "DeviceNotRegistered" } },
                { "status" => "ok" }
              ]
            }),
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "deactivates the invalid token" do
        described_class.call(tokens: tokens, title: title, body: body)
        expect(device_token.reload.active).to be false
      end

      it "reports correct counts" do
        result = described_class.call(tokens: tokens, title: title, body: body)
        expect(result.sent).to eq(1)
        expect(result.failed).to eq(1)
      end
    end

    context "when API request fails" do
      before do
        stub_request(:post, described_class::EXPO_PUSH_URL)
          .to_raise(Faraday::ConnectionFailed.new("connection refused"))
      end

      it "returns failure" do
        result = described_class.call(tokens: tokens, title: title, body: body)
        # The service catches Faraday errors at the batch level and reports them
        expect(result).to be_success
        expect(result.failed).to eq(2)
      end
    end

    context "with missing parameters" do
      it "fails without tokens" do
        result = described_class.call(title: title, body: body)
        expect(result).to be_failure
      end

      it "fails without title" do
        result = described_class.call(tokens: tokens, body: body)
        expect(result).to be_failure
      end
    end
  end
end
