# frozen_string_literal: true

require "rails_helper"

RSpec.describe Waitlists::NotifyService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:tee_sheet) { create(:tee_sheet, course: course) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, max_players: 4, booked_players: 2, status: :partially_booked) }

  describe ".call" do
    subject(:result) { described_class.call(tee_time: tee_time) }

    context "when there are waitlisted users whose request fits" do
      let!(:entry1) { create(:waitlist_entry, tee_time: tee_time, organization: organization, players_requested: 2) }
      let!(:entry2) { create(:waitlist_entry, tee_time: tee_time, organization: organization, players_requested: 1) }

      it "notifies matching waitlisted users" do
        expect { result }.to have_enqueued_mail(WaitlistMailer, :slot_available).exactly(2).times
        expect(result).to be_success
        expect(result.data.notified_count).to eq(2)
      end

      it "marks entries as notified" do
        result
        expect(entry1.reload).to be_notified
        expect(entry2.reload).to be_notified
      end
    end

    context "when a user requests more players than available spots" do
      let!(:entry) { create(:waitlist_entry, tee_time: tee_time, organization: organization, players_requested: 5) }

      it "does not notify that user" do
        expect { result }.not_to have_enqueued_mail(WaitlistMailer, :slot_available)
        expect(result).to be_success
        expect(result.data.notified_count).to eq(0)
        expect(entry.reload).to be_waiting
      end
    end

    context "when there are no active waitlist entries" do
      it "returns success with zero notified" do
        expect(result).to be_success
        expect(result.data.notified_count).to eq(0)
      end
    end

    context "when tee time is in the past" do
      let(:tee_time) { create(:tee_time, :past, tee_sheet: tee_sheet) }

      it "does not notify anyone" do
        create(:waitlist_entry, tee_time: tee_time, organization: organization)
        expect(result).to be_success
        expect(result.data.notified_count).to eq(0)
      end
    end

    context "when tee time has no available spots" do
      let(:tee_time) { create(:tee_time, :fully_booked, tee_sheet: tee_sheet) }

      it "does not notify anyone" do
        create(:waitlist_entry, tee_time: tee_time, organization: organization, players_requested: 1)
        expect(result).to be_success
        expect(result.data.notified_count).to eq(0)
      end
    end

    context "with already notified entries" do
      let!(:notified_entry) { create(:waitlist_entry, :notified, tee_time: tee_time, organization: organization) }
      let!(:waiting_entry) { create(:waitlist_entry, tee_time: tee_time, organization: organization, players_requested: 1) }

      it "only notifies waiting entries" do
        expect { result }.to have_enqueued_mail(WaitlistMailer, :slot_available).once
        expect(result.data.notified_count).to eq(1)
      end
    end
  end
end
