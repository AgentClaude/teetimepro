# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaigns::SendSmsService do
  let(:organization) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:campaign) { create(:sms_campaign, :sending, organization: organization, created_by: manager) }
  let(:user) { create(:user, organization: organization, phone: "+15551234567") }
  let(:sms_message) { create(:sms_message, sms_campaign: campaign, user: user, to_phone: "+15551234567") }

  let(:twilio_client) { instance_double(Twilio::REST::Client) }
  let(:messages_resource) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList) }
  let(:twilio_response) { instance_double(Twilio::REST::Api::V2010::AccountContext::MessageContext::MessageInstance, sid: "SM12345") }

  before do
    allow(TwilioConfig).to receive(:client).and_return(twilio_client)
    allow(TwilioConfig).to receive(:from_number).and_return("+15550001111")
    allow(twilio_client).to receive(:messages).and_return(messages_resource)
  end

  describe ".call" do
    context "when Twilio sends successfully" do
      before do
        allow(messages_resource).to receive(:create).and_return(twilio_response)
      end

      it "sends the SMS and updates the message" do
        result = described_class.call(sms_message: sms_message)

        expect(result).to be_success
        sms_message.reload
        expect(sms_message.twilio_sid).to eq("SM12345")
        expect(sms_message).to be_queued
        expect(sms_message.sent_at).to be_present
      end

      it "calls Twilio with correct params" do
        expect(messages_resource).to receive(:create).with(
          hash_including(
            from: "+15550001111",
            to: "+15551234567",
            body: campaign.message_body
          )
        ).and_return(twilio_response)

        described_class.call(sms_message: sms_message)
      end
    end

    context "when Twilio raises an error" do
      before do
        allow(messages_resource).to receive(:create).and_raise(
          Twilio::REST::RestException.new(400, OpenStruct.new(body: { "code" => 21211, "message" => "Invalid phone" }))
        )
      end

      it "marks the message as failed" do
        result = described_class.call(sms_message: sms_message)

        expect(result).to be_failure
        sms_message.reload
        expect(sms_message).to be_failed
        expect(sms_message.error_code).to be_present
      end
    end

    context "when message is already delivered" do
      let(:sms_message) { create(:sms_message, :delivered, sms_campaign: campaign, user: user) }

      it "returns failure" do
        result = described_class.call(sms_message: sms_message)

        expect(result).to be_failure
        expect(result.errors).to include("Message already sent")
      end
    end
  end
end
