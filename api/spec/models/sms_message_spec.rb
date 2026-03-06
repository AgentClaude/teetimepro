# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmsMessage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:sms_campaign) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:to_phone) }

    it "validates uniqueness of user per campaign" do
      org = create(:organization)
      user = create(:user, organization: org, phone: "+15551234567")
      manager = create(:user, :manager, organization: org)
      campaign = create(:sms_campaign, organization: org, created_by: manager)
      create(:sms_message, sms_campaign: campaign, user: user, to_phone: user.phone)

      duplicate = build(:sms_message, sms_campaign: campaign, user: user, to_phone: user.phone)
      expect(duplicate).not_to be_valid
    end
  end

  describe "#terminal?" do
    it "returns true for delivered messages" do
      expect(build(:sms_message, :delivered).terminal?).to be true
    end

    it "returns true for failed messages" do
      expect(build(:sms_message, :failed).terminal?).to be true
    end

    it "returns false for pending messages" do
      expect(build(:sms_message).terminal?).to be false
    end
  end
end
