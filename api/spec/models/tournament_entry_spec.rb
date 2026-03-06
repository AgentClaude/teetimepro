require "rails_helper"

RSpec.describe TournamentEntry, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tournament) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:payment).optional }
  end

  describe "validations" do
    subject { build(:tournament_entry) }

    it { is_expected.to validate_presence_of(:status) }

    context "uniqueness" do
      let(:tournament) { create(:tournament, :registration_open) }
      let(:user) { create(:user, organization: tournament.organization) }

      it "prevents duplicate entries" do
        create(:tournament_entry, tournament: tournament, user: user)
        duplicate = build(:tournament_entry, tournament: tournament, user: user)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include("is already registered for this tournament")
      end
    end

    context "handicap limit" do
      let(:tournament) { create(:tournament, :registration_open, max_handicap: 18.0) }

      it "rejects handicap above tournament limit" do
        entry = build(:tournament_entry, tournament: tournament, handicap_index: 20.0)
        expect(entry).not_to be_valid
        expect(entry.errors[:handicap_index]).to include("exceeds tournament maximum of 18.0")
      end

      it "allows handicap within limit" do
        entry = build(:tournament_entry, tournament: tournament, handicap_index: 15.0)
        expect(entry).to be_valid
      end
    end

    context "registration availability" do
      it "rejects entry when tournament is draft" do
        tournament = create(:tournament, status: :draft)
        entry = build(:tournament_entry, tournament: tournament)
        expect(entry).not_to be_valid
        expect(entry.errors[:base]).to include("Tournament is not accepting registrations")
      end
    end
  end

  describe "#withdraw!" do
    let(:entry) { create(:tournament_entry, :confirmed) }

    it "changes status to withdrawn" do
      entry.withdraw!
      expect(entry.reload).to be_withdrawn
    end

    it "returns false if already withdrawn" do
      entry.update!(status: :withdrawn)
      expect(entry.withdraw!).to be false
    end
  end
end
