# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaigns::SendCampaignService do
  let(:organization) { create(:organization) }
  let(:manager) { create(:user, :manager, organization: organization) }

  before do
    allow(TwilioConfig).to receive(:configured?).and_return(true)
  end

  describe ".call" do
    context "with valid campaign and recipients" do
      let!(:users_with_phones) do
        3.times.map do
          create(:user, organization: organization, phone: "+1555#{rand(1000000..9999999)}")
        end
      end
      let(:campaign) { create(:sms_campaign, organization: organization, created_by: manager) }

      it "transitions campaign to sending status" do
        result = described_class.call(campaign: campaign)

        expect(result).to be_success
        expect(result.campaign).to be_sending
      end

      it "creates sms_message records for each recipient" do
        described_class.call(campaign: campaign)

        expect(campaign.sms_messages.count).to eq(3)
      end

      it "enqueues SendSmsJob for each message" do
        expect {
          described_class.call(campaign: campaign)
        }.to have_enqueued_job(SendSmsJob).exactly(3).times
      end

      it "sets total_recipients count" do
        described_class.call(campaign: campaign)

        expect(campaign.reload.total_recipients).to eq(3)
      end
    end

    context "with no recipients" do
      let(:campaign) { create(:sms_campaign, organization: organization, created_by: manager) }

      it "fails with no recipients message" do
        # No users with phones in this org
        result = described_class.call(campaign: campaign)

        expect(result).to be_failure
      end
    end

    context "with completed campaign" do
      let(:campaign) { create(:sms_campaign, :completed, organization: organization, created_by: manager) }

      it "fails when campaign cannot be sent" do
        result = described_class.call(campaign: campaign)

        expect(result).to be_failure
        expect(result.errors).to include("Campaign cannot be sent in its current state")
      end
    end

    context "with Twilio not configured" do
      let(:campaign) { create(:sms_campaign, organization: organization, created_by: manager) }

      before do
        allow(TwilioConfig).to receive(:configured?).and_return(false)
      end

      it "fails with configuration error" do
        result = described_class.call(campaign: campaign)

        expect(result).to be_failure
        expect(result.errors).to include("Twilio is not configured")
      end
    end

    context "with members_only filter" do
      let(:campaign) do
        create(:sms_campaign, organization: organization, created_by: manager, recipient_filter: "members_only")
      end

      it "only includes users with active memberships" do
        member = create(:user, organization: organization, phone: "+15551234567")
        create(:membership, user: member, organization: organization, status: :active)
        _non_member = create(:user, organization: organization, phone: "+15559876543")

        result = described_class.call(campaign: campaign)

        expect(result).to be_success
        expect(campaign.sms_messages.count).to eq(1)
        expect(campaign.sms_messages.first.user).to eq(member)
      end
    end
  end
end
