# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaigns::CreateCampaignService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :manager, organization: organization) }

  describe ".call" do
    context "with valid params" do
      it "creates a draft campaign" do
        result = described_class.call(
          organization: organization,
          user: user,
          name: "Spring Special",
          message_body: "Book your tee time this weekend! 20% off."
        )

        expect(result).to be_success
        expect(result.campaign).to be_persisted
        expect(result.campaign).to be_draft
        expect(result.campaign.name).to eq("Spring Special")
        expect(result.campaign.organization).to eq(organization)
        expect(result.campaign.created_by).to eq(user)
      end

      it "creates a scheduled campaign when scheduled_at is provided" do
        schedule_time = 2.hours.from_now
        result = described_class.call(
          organization: organization,
          user: user,
          name: "Weekend Deals",
          message_body: "Don't miss our weekend rates!",
          scheduled_at: schedule_time
        )

        expect(result).to be_success
        expect(result.campaign).to be_scheduled
        expect(result.campaign.scheduled_at).to be_within(1.second).of(schedule_time)
      end

      it "accepts custom recipient filters" do
        result = described_class.call(
          organization: organization,
          user: user,
          name: "Members Only",
          message_body: "Exclusive member rates this week!",
          recipient_filter: "members_only"
        )

        expect(result).to be_success
        expect(result.campaign.recipient_filter).to eq("members_only")
      end
    end

    context "with invalid params" do
      it "fails without a name" do
        result = described_class.call(
          organization: organization,
          user: user,
          name: nil,
          message_body: "Hello!"
        )

        expect(result).to be_failure
      end

      it "fails without a message body" do
        result = described_class.call(
          organization: organization,
          user: user,
          name: "Test",
          message_body: nil
        )

        expect(result).to be_failure
      end
    end
  end
end
