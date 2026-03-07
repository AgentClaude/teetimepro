require "rails_helper"

RSpec.describe TournamentRound, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tournament) }
    it { is_expected.to have_many(:tournament_scores).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:tournament_round) }

    it { is_expected.to validate_presence_of(:round_number) }
    it { is_expected.to validate_presence_of(:play_date) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_numericality_of(:round_number).is_greater_than(0) }

    it "validates uniqueness of round_number scoped to tournament" do
      round = create(:tournament_round)
      duplicate = build(:tournament_round, tournament: round.tournament, round_number: round.round_number)
      expect(duplicate).not_to be_valid
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(not_started: 0, in_progress: 1, completed: 2) }
  end

  describe "scopes" do
    it ".chronological orders by round_number" do
      tournament = create(:tournament, :in_progress)
      round2 = create(:tournament_round, tournament: tournament, round_number: 2, play_date: tournament.start_date + 1)
      round1 = create(:tournament_round, tournament: tournament, round_number: 1)

      expect(TournamentRound.chronological).to eq([round1, round2])
    end
  end
end
