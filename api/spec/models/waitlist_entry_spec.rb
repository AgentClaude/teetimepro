# frozen_string_literal: true

require "rails_helper"

RSpec.describe WaitlistEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:tee_time) }
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:players_requested) }
    it { is_expected.to validate_numericality_of(:players_requested).is_in(1..5) }

    context "uniqueness" do
      subject { create(:waitlist_entry) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:tee_time_id).with_message("is already on the waitlist for this tee time") }
    end

    context "tee_time_must_be_in_future" do
      it "rejects past tee times" do
        tee_time = create(:tee_time, :past)
        entry = build(:waitlist_entry, tee_time: tee_time)
        expect(entry).not_to be_valid
        expect(entry.errors[:tee_time]).to include("must be in the future")
      end
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(waiting: 0, notified: 1, expired: 2, cancelled: 3) }
  end

  describe "scopes" do
    let(:organization) { create(:organization) }
    let(:course) { create(:course, organization: organization) }
    let(:tee_sheet) { create(:tee_sheet, course: course) }
    let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet) }

    describe ".active" do
      it "returns only waiting entries" do
        waiting = create(:waitlist_entry, tee_time: tee_time, organization: organization)
        create(:waitlist_entry, :notified, tee_time: tee_time, organization: organization)

        expect(described_class.active).to eq([waiting])
      end
    end

    describe ".for_tee_time" do
      it "filters by tee time" do
        entry = create(:waitlist_entry, tee_time: tee_time, organization: organization)
        other_tee_time = create(:tee_time, tee_sheet: tee_sheet)
        create(:waitlist_entry, tee_time: other_tee_time, organization: organization)

        expect(described_class.for_tee_time(tee_time)).to eq([entry])
      end
    end
  end

  describe "#notify!" do
    it "marks entry as notified with timestamp" do
      entry = create(:waitlist_entry)
      freeze_time do
        entry.notify!
        expect(entry.reload).to be_notified
        expect(entry.notified_at).to eq(Time.current)
      end
    end
  end

  describe "#expire!" do
    it "marks entry as expired with timestamp" do
      entry = create(:waitlist_entry)
      freeze_time do
        entry.expire!
        expect(entry.reload).to be_expired
        expect(entry.expired_at).to eq(Time.current)
      end
    end
  end
end
