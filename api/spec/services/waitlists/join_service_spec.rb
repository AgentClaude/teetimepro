# frozen_string_literal: true

require "rails_helper"

RSpec.describe Waitlists::JoinService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, :fully_booked, tee_sheet: tee_sheet) }
  let(:user) { create(:user, organization: organization) }

  describe ".call" do
    subject(:result) do
      described_class.call(
        user: user,
        tee_time: tee_time,
        organization: organization,
        players_requested: 2
      )
    end

    context "when valid" do
      it "creates a waitlist entry" do
        expect { result }.to change(WaitlistEntry, :count).by(1)
        expect(result).to be_success
        expect(result.data.waitlist_entry).to be_a(WaitlistEntry)
        expect(result.data.waitlist_entry.status).to eq("waiting")
        expect(result.data.waitlist_entry.players_requested).to eq(2)
      end
    end

    context "when user is already waitlisted" do
      before { create(:waitlist_entry, user: user, tee_time: tee_time, organization: organization) }

      it "returns failure" do
        expect(result).to be_failure
        expect(result.errors).to include("You are already on the waitlist for this tee time")
      end
    end

    context "when tee time is in the past" do
      let(:tee_time) { create(:tee_time, :past, tee_sheet: tee_sheet) }

      it "returns failure" do
        expect(result).to be_failure
        expect(result.errors).to include("Tee time must be in the future")
      end
    end

    context "when players_requested is invalid" do
      subject(:result) do
        described_class.call(
          user: user,
          tee_time: tee_time,
          organization: organization,
          players_requested: 0
        )
      end

      it "returns validation failure" do
        expect(result).to be_failure
      end
    end

    context "when user has a cancelled waitlist entry" do
      before { create(:waitlist_entry, :cancelled, user: user, tee_time: tee_time, organization: organization) }

      it "allows re-joining" do
        expect(result).to be_success
      end
    end
  end
end
