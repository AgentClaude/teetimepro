# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushNotifications::RegisterDeviceService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:token) { "ExponentPushToken[abc123]" }
  let(:platform) { "ios" }
  let(:device_id) { "device-uuid-123" }

  describe ".call" do
    context "with valid parameters" do
      it "creates a new device token" do
        result = described_class.call(
          user: user,
          token: token,
          platform: platform,
          device_id: device_id
        )

        expect(result).to be_success
        expect(result.device_token).to be_persisted
        expect(result.device_token.token).to eq(token)
        expect(result.device_token.platform).to eq(platform)
        expect(result.device_token.organization).to eq(organization)
        expect(result.device_token.active).to be true
      end
    end

    context "when token already exists" do
      let!(:existing) { create(:device_token, user: user, token: token, platform: "android") }

      it "updates the existing token" do
        result = described_class.call(
          user: user,
          token: token,
          platform: platform,
          device_id: device_id
        )

        expect(result).to be_success
        expect(result.device_token.id).to eq(existing.id)
        expect(result.device_token.platform).to eq(platform)
      end
    end

    context "when device_id has old tokens" do
      let!(:old_token) do
        create(:device_token, user: user, device_id: device_id, active: true)
      end

      it "deactivates old tokens for same device" do
        described_class.call(
          user: user,
          token: token,
          platform: platform,
          device_id: device_id
        )

        expect(old_token.reload.active).to be false
      end
    end

    context "with missing parameters" do
      it "fails without user" do
        result = described_class.call(token: token, platform: platform)
        expect(result).to be_failure
      end

      it "fails without token" do
        result = described_class.call(user: user, platform: platform)
        expect(result).to be_failure
      end

      it "fails with invalid platform" do
        result = described_class.call(user: user, token: token, platform: "windows")
        expect(result).to be_failure
      end
    end
  end
end
