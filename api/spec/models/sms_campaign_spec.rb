# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmsCampaign, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:sms_messages).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:message_body) }
    it { is_expected.to validate_length_of(:message_body).is_at_most(1600) }
  end

  describe "enums" do
    it {
      is_expected.to define_enum_for(:status)
        .with_values(draft: 0, scheduled: 1, sending: 2, completed: 3, cancelled: 4, failed: 5)
    }
  end

  describe "#progress_percentage" do
    it "returns 0 when no recipients" do
      campaign = build(:sms_campaign, total_recipients: 0)
      expect(campaign.progress_percentage).to eq(0)
    end

    it "calculates correct percentage" do
      campaign = build(:sms_campaign, total_recipients: 10, sent_count: 7, failed_count: 1)
      expect(campaign.progress_percentage).to eq(80.0)
    end
  end

  describe "#can_send?" do
    it "returns true for draft campaigns" do
      expect(build(:sms_campaign, status: :draft).can_send?).to be true
    end

    it "returns true for scheduled campaigns" do
      expect(build(:sms_campaign, status: :scheduled).can_send?).to be true
    end

    it "returns false for sending campaigns" do
      expect(build(:sms_campaign, status: :sending).can_send?).to be false
    end

    it "returns false for completed campaigns" do
      expect(build(:sms_campaign, status: :completed).can_send?).to be false
    end
  end

  describe "#can_cancel?" do
    it "returns true for draft campaigns" do
      expect(build(:sms_campaign, status: :draft).can_cancel?).to be true
    end

    it "returns false for completed campaigns" do
      expect(build(:sms_campaign, status: :completed).can_cancel?).to be false
    end
  end

  describe ".pending_send" do
    it "finds scheduled campaigns past their send time" do
      org = create(:organization)
      user = create(:user, :manager, organization: org)
      past = create(:sms_campaign, :scheduled, organization: org, created_by: user, scheduled_at: 1.hour.ago)
      _future = create(:sms_campaign, :scheduled, organization: org, created_by: user, scheduled_at: 1.hour.from_now)

      expect(SmsCampaign.pending_send).to contain_exactly(past)
    end
  end
end
