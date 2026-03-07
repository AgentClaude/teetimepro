require "rails_helper"

RSpec.describe Leaderboard::CalculateService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }

  # Create tournament as registration_open so entries can be created, then switch to in_progress
  let(:tournament) do
    t = create(:tournament, :registration_open, organization: organization, course: course, holes: 18)
    t
  end

  let(:player1) { create(:user, organization: organization, first_name: "Tiger", last_name: "Woods") }
  let(:player2) { create(:user, organization: organization, first_name: "Rory", last_name: "McIlroy") }
  let(:player3) { create(:user, organization: organization, first_name: "Phil", last_name: "Mickelson") }

  let(:entry1) { create(:tournament_entry, tournament: tournament, user: player1, status: :confirmed) }
  let(:entry2) { create(:tournament_entry, tournament: tournament, user: player2, status: :confirmed) }
  let(:entry3) { create(:tournament_entry, tournament: tournament, user: player3, status: :confirmed) }

  let(:round) { create(:tournament_round, :in_progress, tournament: tournament, round_number: 1) }

  before do
    # Force-create entries while tournament is in registration_open, then switch to in_progress
    entry1; entry2; entry3
    tournament.update_column(:status, Tournament.statuses[:in_progress])
    tournament.reload

    # Player 1: -2 through 3 holes (birdie, par, birdie)
    create(:tournament_score, tournament_round: round, tournament_entry: entry1, hole_number: 1, strokes: 3, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry1, hole_number: 2, strokes: 4, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry1, hole_number: 3, strokes: 4, par: 5)

    # Player 2: even par through 3 holes
    create(:tournament_score, tournament_round: round, tournament_entry: entry2, hole_number: 1, strokes: 4, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry2, hole_number: 2, strokes: 4, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry2, hole_number: 3, strokes: 5, par: 5)

    # Player 3: +1 through 3 holes
    create(:tournament_score, tournament_round: round, tournament_entry: entry3, hole_number: 1, strokes: 5, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry3, hole_number: 2, strokes: 4, par: 4)
    create(:tournament_score, tournament_round: round, tournament_entry: entry3, hole_number: 3, strokes: 5, par: 5)
  end

  describe ".call" do
    it "returns a successful result" do
      result = described_class.call(tournament: tournament)
      expect(result).to be_success
    end

    it "ranks players correctly by score to par" do
      result = described_class.call(tournament: tournament)
      entries = result.data[:entries]

      expect(entries[0][:player_name]).to eq("Tiger Woods")
      expect(entries[0][:total_to_par]).to eq(-2)
      expect(entries[0][:position]).to eq(1)

      expect(entries[1][:player_name]).to eq("Rory McIlroy")
      expect(entries[1][:total_to_par]).to eq(0)
      expect(entries[1][:position]).to eq(2)

      expect(entries[2][:player_name]).to eq("Phil Mickelson")
      expect(entries[2][:total_to_par]).to eq(1)
      expect(entries[2][:position]).to eq(3)
    end

    it "correctly calculates total strokes" do
      result = described_class.call(tournament: tournament)
      entries = result.data[:entries]

      expect(entries[0][:total_strokes]).to eq(11)  # 3+4+4
      expect(entries[1][:total_strokes]).to eq(13)  # 4+4+5
      expect(entries[2][:total_strokes]).to eq(14)  # 5+4+5
    end

    it "tracks holes played" do
      result = described_class.call(tournament: tournament)
      entries = result.data[:entries]

      expect(entries[0][:total_holes_played]).to eq(3)
    end

    it "detects tied positions" do
      # Make player 3 match player 2 (even par)
      TournamentScore.find_by(tournament_entry: entry3, hole_number: 1).update!(strokes: 4)

      result = described_class.call(tournament: tournament)
      entries = result.data[:entries]

      tied_entries = entries.select { |e| e[:total_to_par] == 0 }
      expect(tied_entries.size).to eq(2)
      expect(tied_entries.all? { |e| e[:tied] }).to be true
      expect(tied_entries.all? { |e| e[:position] == 2 }).to be true
    end

    it "includes round breakdown" do
      result = described_class.call(tournament: tournament)
      first_entry = result.data[:entries].first

      expect(first_entry[:rounds]).to be_an(Array)
      expect(first_entry[:rounds].first[:round_number]).to eq(1)
      expect(first_entry[:rounds].first[:holes_played]).to eq(3)
    end

    it "returns current round info" do
      result = described_class.call(tournament: tournament)

      expect(result.data[:tournament_id]).to eq(tournament.id)
      expect(result.data[:total_rounds]).to eq(1)
      expect(result.data[:current_round]).to eq(1)
    end

    context "with withdrawn entries" do
      before do
        entry3.update!(status: :withdrawn)
      end

      it "excludes withdrawn players" do
        result = described_class.call(tournament: tournament)
        names = result.data[:entries].map { |e| e[:player_name] }

        expect(names).not_to include("Phil Mickelson")
        expect(result.data[:entries].size).to eq(2)
      end
    end

    context "with no scores" do
      let(:empty_tournament) do
        t = create(:tournament, :registration_open, organization: organization, course: course)
        t
      end

      let!(:empty_entry) do
        e = create(:tournament_entry, tournament: empty_tournament, user: player1, status: :confirmed)
        empty_tournament.update_column(:status, Tournament.statuses[:in_progress])
        empty_tournament.reload
        e
      end

      it "returns entries with zero scores" do
        result = described_class.call(tournament: empty_tournament)

        expect(result).to be_success
        expect(result.data[:entries].first[:total_strokes]).to eq(0)
        expect(result.data[:entries].first[:total_to_par]).to eq(0)
      end
    end
  end
end
