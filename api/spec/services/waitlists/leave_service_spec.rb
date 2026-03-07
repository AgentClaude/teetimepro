# frozen_string_literal: true

require "rails_helper"

RSpec.describe Waitlists::LeaveService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, :fully_booked, tee_sheet: tee_sheet) }
  let(:user) { create(:user, organization: organization) }

  describe ".call" do
    context "when user is on the waitlist" do
      let!(:entry) { create(:waitlist_entry, user: user, tee_time: tee_time, organization: organization) }

      it "cancels the waitlist entry" do
        result = described_class.call(user: user, tee_time: tee_time)
        expect(result).to be_success
        expect(entry.reload).to be_cancelled
      end
    end

    context "when user is not on the waitlist" do
      it "returns failure" do
        result = described_class.call(user: user, tee_time: tee_time)
        expect(result).to be_failure
        expect(result.errors).to include("You are not on the waitlist for this tee time")
      end
    end
  end
end
