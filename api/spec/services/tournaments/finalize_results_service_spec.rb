require 'rails_helper'

RSpec.describe Tournaments::FinalizeResultsService, type: :service do
  let(:organization) { create(:organization) }
  let(:tournament) { create(:tournament, :in_progress, organization: organization) }
  let!(:round) { create(:tournament_round, tournament: tournament, round_number: 1, status: :completed) }
  
  # Create some entries with different scores
  let!(:entry1) { create(:tournament_entry, tournament: tournament) }
  let!(:entry2) { create(:tournament_entry, tournament: tournament) }
  let!(:entry3) { create(:tournament_entry, tournament: tournament) }
  
  # Mock leaderboard data that would come from Leaderboard::CalculateService
  let(:mock_leaderboard_entries) do
    [
      {
        entry_id: entry1.id,
        position: 1,
        total_strokes: 69,
        total_to_par: -3,
        tied: false
      },
      {
        entry_id: entry2.id,
        position: 2,
        total_strokes: 72,
        total_to_par: 0,
        tied: false
      },
      {
        entry_id: entry3.id,
        position: 3,
        total_strokes: 75,
        total_to_par: 3,
        tied: false
      }
    ]
  end

  let(:mock_leaderboard_result) do
    ServiceResult.new(
      success: true,
      data: { entries: mock_leaderboard_entries }
    )
  end

  before do
    allow(Leaderboard::CalculateService).to receive(:call)
      .with(tournament: tournament)
      .and_return(mock_leaderboard_result)
  end

  describe '.call' do
    context 'with valid tournament ready for finalization' do
      let!(:prize1) { create(:tournament_prize, tournament: tournament, position: 1, amount_cents: 50000) }
      let!(:prize2) { create(:tournament_prize, tournament: tournament, position: 2, amount_cents: 25000) }
      let!(:prize3) { create(:tournament_prize, tournament: tournament, position: 3, amount_cents: 10000) }
      
      let(:service) { described_class.new(tournament: tournament) }

      it 'creates tournament results and awards prizes successfully' do
        result = service.call
        
        expect(result).to be_success
        expect(result.data[:results]).to have(3).items
        expect(result.data[:awarded_prizes]).to have(3).items
        
        # Check results were created
        results = tournament.tournament_results.reload
        expect(results.count).to eq(3)
        
        winner_result = results.find_by(position: 1)
        expect(winner_result.tournament_entry).to eq(entry1)
        expect(winner_result.total_strokes).to eq(69)
        expect(winner_result.total_to_par).to eq(-3)
        expect(winner_result.tied).to be false
        expect(winner_result.finalized_at).to be_present
        expect(winner_result.prize_awarded).to be true
        
        # Check prizes were awarded
        expect(prize1.reload.awarded_to).to eq(entry1)
        expect(prize2.reload.awarded_to).to eq(entry2)
        expect(prize3.reload.awarded_to).to eq(entry3)
        
        # Check tournament status updated
        expect(tournament.reload.status).to eq('completed')
      end

      it 'replaces existing results' do
        # Create some old results
        create(:tournament_result, tournament: tournament, tournament_entry: entry1, position: 5)
        
        result = service.call
        
        expect(result).to be_success
        expect(tournament.tournament_results.reload.count).to eq(3)
        expect(tournament.tournament_results.find_by(position: 5)).to be_nil
      end

      it 'calls Leaderboard::CalculateService' do
        service.call
        
        expect(Leaderboard::CalculateService).to have_received(:call).with(tournament: tournament)
      end
    end

    context 'when tournament is already completed' do
      let(:completed_tournament) { create(:tournament, :completed, organization: organization) }
      let(:service) { described_class.new(tournament: completed_tournament) }

      before do
        allow(Leaderboard::CalculateService).to receive(:call)
          .with(tournament: completed_tournament)
          .and_return(mock_leaderboard_result)
      end

      it 'works for completed tournaments' do
        result = service.call
        
        expect(result).to be_success
        # Tournament status should remain completed (not changed)
        expect(completed_tournament.reload.status).to eq('completed')
      end
    end

    context 'with invalid tournament state' do
      it 'fails for draft tournament' do
        draft_tournament = create(:tournament, status: :draft, organization: organization)
        service = described_class.new(tournament: draft_tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament must be completed or in progress to finalize results')
      end

      it 'fails for cancelled tournament' do
        cancelled_tournament = create(:tournament, status: :cancelled, organization: organization)
        service = described_class.new(tournament: cancelled_tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament must be completed or in progress to finalize results')
      end

      it 'fails when in_progress tournament has incomplete rounds' do
        incomplete_round = create(:tournament_round, tournament: tournament, round_number: 2, status: :in_progress)
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament cannot finalize results with incomplete rounds')
      end

      it 'fails when tournament has no active entries' do
        entry1.destroy
        entry2.destroy
        entry3.destroy
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament cannot finalize results with no active entries')
      end
    end

    context 'when leaderboard calculation fails' do
      let(:failed_leaderboard_result) do
        ServiceResult.new(
          success: false,
          errors: ['Failed to calculate leaderboard']
        )
      end

      before do
        allow(Leaderboard::CalculateService).to receive(:call)
          .with(tournament: tournament)
          .and_return(failed_leaderboard_result)
      end

      it 'returns failure with leaderboard error' do
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Failed to calculate leaderboard: Failed to calculate leaderboard')
      end
    end

    context 'with tied positions' do
      let(:tied_leaderboard_entries) do
        [
          {
            entry_id: entry1.id,
            position: 1,
            total_strokes: 70,
            total_to_par: -2,
            tied: true
          },
          {
            entry_id: entry2.id,
            position: 1,
            total_strokes: 70,
            total_to_par: -2,
            tied: true
          },
          {
            entry_id: entry3.id,
            position: 3,
            total_strokes: 72,
            total_to_par: 0,
            tied: false
          }
        ]
      end

      let(:tied_leaderboard_result) do
        ServiceResult.new(
          success: true,
          data: { entries: tied_leaderboard_entries }
        )
      end

      before do
        allow(Leaderboard::CalculateService).to receive(:call)
          .with(tournament: tournament)
          .and_return(tied_leaderboard_result)
      end

      it 'handles tied positions correctly' do
        prize1 = create(:tournament_prize, tournament: tournament, position: 1, amount_cents: 50000)
        prize3 = create(:tournament_prize, tournament: tournament, position: 3, amount_cents: 10000)
        
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_success
        
        # Check tied results
        tied_results = tournament.tournament_results.where(position: 1, tied: true)
        expect(tied_results.count).to eq(2)
        
        # First place prize should go to first tied entry
        expect(prize1.reload.awarded_to).to eq(entry1)
        expect(prize3.reload.awarded_to).to eq(entry3)
      end
    end

    context 'with missing prizes' do
      it 'works even when no prizes are defined' do
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_success
        expect(result.data[:results]).to have(3).items
        expect(result.data[:awarded_prizes]).to be_empty
        
        # Results should still be created without prizes
        results = tournament.tournament_results.reload
        expect(results.count).to eq(3)
        expect(results.all? { |r| !r.prize_awarded }).to be true
      end
    end

    context 'with missing parameters' do
      it 'fails without tournament' do
        service = described_class.new
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament can\'t be blank')
      end
    end
  end
end