# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmailProvider, type: :model do
  describe "validations" do
    subject { build(:email_provider) }

    it { is_expected.to be_valid }

    it "requires provider_type" do
      subject.provider_type = nil
      expect(subject).not_to be_valid
    end

    it "requires api_key" do
      subject.api_key = nil
      expect(subject).not_to be_valid
    end

    it "requires from_email" do
      subject.from_email = nil
      expect(subject).not_to be_valid
    end

    it "validates from_email format" do
      subject.from_email = "not-an-email"
      expect(subject).not_to be_valid
    end

    it "validates uniqueness of provider_type per organization" do
      existing = create(:email_provider, :sendgrid)
      duplicate = build(:email_provider, :sendgrid, organization: existing.organization)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:provider_type]).to include("already configured for this organization")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
  end

  describe "scopes" do
    let(:org) { create(:organization) }

    it ".active returns only active providers" do
      active = create(:email_provider, organization: org)
      create(:email_provider, :mailchimp, :inactive, organization: org)
      expect(EmailProvider.active).to contain_exactly(active)
    end

    it ".verified returns only verified providers" do
      verified = create(:email_provider, organization: org)
      create(:email_provider, :mailchimp, :unverified, organization: org)
      expect(EmailProvider.verified).to contain_exactly(verified)
    end
  end

  describe "#adapter" do
    it "returns SendgridAdapter for sendgrid type" do
      provider = build(:email_provider, :sendgrid)
      expect(provider.adapter).to be_a(EmailProviders::SendgridAdapter)
    end

    it "returns MailchimpAdapter for mailchimp type" do
      provider = build(:email_provider, :mailchimp)
      expect(provider.adapter).to be_a(EmailProviders::MailchimpAdapter)
    end
  end

  describe "#masked_api_key" do
    it "masks the middle of the API key" do
      provider = build(:email_provider, api_key: "SG.abcdefghijklmnop")
      masked = provider.masked_api_key
      expect(masked).to start_with("SG.a")
      expect(masked).to end_with("mnop")
      expect(masked).to include("*")
    end
  end

  describe "#ensure_single_default" do
    let(:org) { create(:organization) }

    it "unsets other defaults when setting a new default" do
      first = create(:email_provider, :sendgrid, organization: org, is_default: true)
      second = create(:email_provider, :mailchimp, organization: org, is_default: true)

      first.reload
      expect(first.is_default).to be false
      expect(second.is_default).to be true
    end
  end
end
