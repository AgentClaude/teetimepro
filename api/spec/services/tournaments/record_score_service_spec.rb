require "rails_helper"

RSpec.describe Tournaments::RecordScoreService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization, role: :staff) }

  # Create tournament as registration_open, add entries, then switch to in_progress
  let(:tournament) do
    create(:tournament, :registration_open, organization: organization, course: course)
  end

  let(:entry_user) { create(:user, organization: organization) }
  let(:entry) { create(:tournament_entry, tournament: tournament, user: entry_user) }
  let(:round) { create(:tournament_round, :in_progress, tournament: tournament) }

  before do
    # Create entry while registration is open, then switch to in_progress
    entry
    tournament.update_column(:status, Tournament.statuses[:in_progress])
    tournament.reload
  end

  let(:valid_params) do
    {
      tournament: tournament,
      tournament_entry: entry,
      tournament_round: round,
      hole_number: 1,
      strokes: 4,
      par: 4,
      current_user: user
    }
  end

  describe ".call" do
    it "creates a new score" do
      result = described_class.call(**valid_params)

      expect(result).to be_success
      expect(result.data[:score]).to be_persisted
      expect(result.data[:score].strokes).to eq(4)
      expect(result.data[:score].par).to eq(4)
    end

    it "updates an existing score for the same hole" do
      described_class.call(**valid_params)

      result = described_class.call(**valid_params.merge(strokes: 5))

      expect(result).to be_success
      expect(TournamentScore.count).to eq(1)
      expect(result.data[:score].strokes).to eq(5)
    end

    it "records optional stats" do
      result = described_class.call(**valid_params.merge(
        putts: 2,
        fairway_hit: true,
        green_in_regulation: false
      ))

      score = result.data[:score]
      expect(score.putts).to eq(2)
      expect(score.fairway_hit).to be true
      expect(score.green_in_regulation).to be false
    end

    it "fails if tournament is not in progress" do
      tournament.update_column(:status, Tournament.statuses[:draft])
      tournament.reload

      result = described_class.call(**valid_params)

      expect(result).not_to be_success
      expect(result.errors).to include("Tournament is not in progress")
    end

    it "fails if round is completed" do
      round.update!(status: :completed)

      result = described_class.call(**valid_params)

      expect(result).not_to be_success
      expect(result.errors).to include("Round is completed")
    end

    it "fails if entry doesn't belong to tournament" do
      other_tournament = create(:tournament, :registration_open, organization: organization, course: course)
      other_entry = create(:tournament_entry, tournament: other_tournament, user: create(:user, organization: organization))
      other_tournament.update_column(:status, Tournament.statuses[:in_progress])

      result = described_class.call(**valid_params.merge(tournament_entry: other_entry))

      expect(result).not_to be_success
      expect(result.errors).to include("Entry does not belong to this tournament")
    end

    it "broadcasts leaderboard update via ActionCable" do
      expect(ActionCable.server).to receive(:broadcast).with(
        "leaderboard_#{tournament.id}",
        hash_including(type: "leaderboard_update", tournament_id: tournament.id)
      )

      described_class.call(**valid_params)
    end

    it "sets round to in_progress if not_started" do
      round.update!(status: :not_started)

      described_class.call(**valid_params)

      expect(round.reload).to be_in_progress
    end
  end
end
