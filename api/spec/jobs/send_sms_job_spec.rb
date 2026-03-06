# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendSmsJob, type: :job do
  let(:organization) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: organization) }
  let(:campaign) { create(:sms_campaign, :sending, organization: organization, created_by: manager) }
  let(:user) { create(:user, organization: organization, phone: "+15551234567") }
  let(:sms_message) { create(:sms_message, sms_campaign: campaign, user: user, to_phone: "+15551234567") }

  it "calls SendSmsService with the message" do
    expect(Campaigns::SendSmsService).to receive(:call).with(sms_message: sms_message)
    described_class.perform_now(sms_message.id)
  end

  it "is enqueued in the sms queue" do
    expect {
      described_class.perform_later(sms_message.id)
    }.to have_enqueued_job.on_queue("sms")
  end
end
