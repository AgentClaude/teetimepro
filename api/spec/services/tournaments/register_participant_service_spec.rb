require "rails_helper"

RSpec.describe Tournaments::RegisterParticipantService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }
  let(:manager) { create(:user, organization: org, role: :manager) }
  let(:golfer) { create(:user, organization: org, role: :golfer) }
  let(:tournament) { create(:tournament, :registration_open, :free, organization: org, course: course, created_by: manager) }

  describe ".call" do
    it "registers a participant" do
      result = described_class.call(tournament: tournament, user: golfer)

      expect(result).to be_success
      entry = result.data.entry
      expect(entry.user).to eq(golfer)
      expect(entry.tournament).to eq(tournament)
      expect(entry).to be_confirmed # free tournament = auto-confirm
    end

    it "prevents duplicate registration" do
      described_class.call(tournament: tournament, user: golfer)
      result = described_class.call(tournament: tournament, user: golfer)

      expect(result).to be_failure
      expect(result.errors.first).to include("Already registered")
    end

    it "rejects registration when tournament is full" do
      tournament.update!(max_participants: 1)
      other_golfer = create(:user, organization: org, role: :golfer)
      described_class.call(tournament: tournament, user: other_golfer)

      result = described_class.call(tournament: tournament, user: golfer)
      expect(result).to be_failure
      expect(result.errors.first).to include("not accepting registrations")
    end

    it "rejects registration for draft tournament" do
      draft = create(:tournament, organization: org, course: course, created_by: manager, status: :draft)
      result = described_class.call(tournament: draft, user: golfer)

      expect(result).to be_failure
      expect(result.errors.first).to include("not accepting registrations")
    end

    it "uses handicap_index from golfer profile when not provided" do
      profile = create(:golfer_profile, user: golfer, handicap_index: 12.5)
      result = described_class.call(tournament: tournament, user: golfer)

      expect(result.data.entry.handicap_index).to eq(12.5)
    end

    it "uses provided handicap_index over profile" do
      create(:golfer_profile, user: golfer, handicap_index: 12.5)
      result = described_class.call(tournament: tournament, user: golfer, handicap_index: 14.0)

      expect(result.data.entry.handicap_index).to eq(14.0)
    end
  end
end
