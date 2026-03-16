# frozen_string_literal: true

require "rails_helper"

RSpec.describe PushNotifications::SendBookingReminderPushService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: 1.day.from_now) }
  let(:booking) { create(:booking, user: user, tee_time: tee_time, organization: organization) }

  before do
    stub_request(:post, PushNotifications::SendPushNotificationService::EXPO_PUSH_URL)
      .to_return(
        status: 200,
        body: Oj.dump({ "data" => [{ "status" => "ok" }] }),
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe ".call" do
    context "when user has device tokens" do
      let!(:device_token) { create(:device_token, user: user, active: true) }

      it "sends a 24h reminder push" do
        result = described_class.call(booking: booking, reminder_type: "24h")

        expect(result).to be_success
        expect(WebMock).to have_requested(:post, PushNotifications::SendPushNotificationService::EXPO_PUSH_URL)
          .with { |req|
            messages = Oj.load(req.body)
            messages.first["title"].include?("Tomorrow")
          }
      end

      it "sends a morning_of reminder push" do
        result = described_class.call(booking: booking, reminder_type: "morning_of")

        expect(result).to be_success
        expect(WebMock).to have_requested(:post, PushNotifications::SendPushNotificationService::EXPO_PUSH_URL)
          .with { |req|
            messages = Oj.load(req.body)
            messages.first["title"].include?("Today")
          }
      end
    end

    context "when user has no device tokens" do
      it "returns success with no_device_tokens reason" do
        result = described_class.call(booking: booking, reminder_type: "24h")

        expect(result).to be_success
        expect(result.reason).to eq("no_device_tokens")
        expect(result.sent).to eq(0)
      end
    end

    context "with invalid reminder type" do
      it "returns failure" do
        result = described_class.call(booking: booking, reminder_type: "invalid")
        expect(result).to be_failure
      end
    end

    context "without booking" do
      it "returns failure" do
        result = described_class.call(reminder_type: "24h")
        expect(result).to be_failure
      end
    end
  end
end
