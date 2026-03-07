require 'rails_helper'

RSpec.describe TournamentResult, type: :model do
  let(:organization) { create(:organization) }
  let(:tournament) { create(:tournament, organization: organization) }
  let(:tournament_entry) { create(:tournament_entry, tournament: tournament) }

  describe 'associations' do
    it { should belong_to(:tournament) }
    it { should belong_to(:tournament_entry) }
    it { should have_one(:user).through(:tournament_entry) }
  end

  describe 'validations' do
    subject { build(:tournament_result, tournament: tournament, tournament_entry: tournament_entry) }

    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).is_greater_than(0) }
    it { should validate_presence_of(:total_strokes) }
    it { should validate_numericality_of(:total_strokes).is_greater_than(0) }
    it { should validate_presence_of(:total_to_par) }

    it 'validates tournament_entry uniqueness within tournament' do
      create(:tournament_result, tournament: tournament, tournament_entry: tournament_entry)
      duplicate = build(:tournament_result, tournament: tournament, tournament_entry: tournament_entry)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:tournament_entry_id]).to include('already has a result for this tournament')
    end

    it 'allows same tournament_entry in different tournaments' do
      other_tournament = create(:tournament, organization: organization)
      create(:tournament_result, tournament: tournament, tournament_entry: tournament_entry)
      other_entry = create(:tournament_entry, tournament: other_tournament, user: tournament_entry.user)
      duplicate = build(:tournament_result, tournament: other_tournament, tournament_entry: other_entry)
      expect(duplicate).to be_valid
    end

    describe 'position uniqueness validation' do
      it 'validates position uniqueness when not tied' do
        create(:tournament_result, tournament: tournament, position: 1, tied: false)
        duplicate = build(:tournament_result, tournament: tournament, position: 1, tied: false)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:position]).to include('already exists for this tournament unless tied')
      end

      it 'allows duplicate positions when tied' do
        create(:tournament_result, tournament: tournament, position: 1, tied: true)
        duplicate = build(:tournament_result, tournament: tournament, position: 1, tied: true)
        expect(duplicate).to be_valid
      end

      it 'allows same position in different tournaments' do
        other_tournament = create(:tournament, organization: organization)
        create(:tournament_result, tournament: tournament, position: 1)
        other_entry = create(:tournament_entry, tournament: other_tournament)
        duplicate = build(:tournament_result, tournament: other_tournament, tournament_entry: other_entry, position: 1)
        expect(duplicate).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:first_place) { create(:tournament_result, tournament: tournament, position: 1, total_to_par: -2, total_strokes: 70) }
    let!(:third_place) { create(:tournament_result, tournament: tournament, position: 3, total_to_par: 1, total_strokes: 73) }
    let!(:second_place) { create(:tournament_result, tournament: tournament, position: 2, total_to_par: 0, total_strokes: 72) }
    let!(:other_tournament_result) { create(:tournament_result, position: 1) }

    describe '.for_tournament' do
      it 'returns results for the specified tournament' do
        expect(TournamentResult.for_tournament(tournament)).to contain_exactly(first_place, second_place, third_place)
      end
    end

    describe '.podium' do
      it 'returns top 3 positions' do
        expect(TournamentResult.podium).to contain_exactly(first_place, second_place, third_place)
      end
    end

    describe '.by_position' do
      it 'orders results by position, then by score' do
        expect(TournamentResult.by_position).to eq([first_place, second_place, third_place, other_tournament_result])
      end
    end

    describe '.finalized' do
      let!(:finalized_result) { create(:tournament_result, tournament: tournament, position: 4, finalized_at: 1.hour.ago) }
      let!(:not_finalized_result) { create(:tournament_result, tournament: tournament, position: 5, finalized_at: nil) }

      it 'returns only finalized results' do
        expect(TournamentResult.finalized).to include(first_place, second_place, third_place, finalized_result)
        expect(TournamentResult.finalized).not_to include(not_finalized_result)
      end
    end
  end

  describe 'methods' do
    let(:tournament_result) { create(:tournament_result, tournament: tournament, tournament_entry: tournament_entry, finalized_at: 1.hour.ago) }

    describe '#finalized?' do
      it 'returns true when finalized' do
        expect(tournament_result.finalized?).to be true
      end

      it 'returns false when not finalized' do
        tournament_result.update!(finalized_at: nil)
        expect(tournament_result.finalized?).to be false
      end
    end

    describe '#prize_eligible?' do
      it 'returns true for non-tied positions' do
        tournament_result.update!(tied: false, position: 5)
        expect(tournament_result.prize_eligible?).to be true
      end

      it 'returns true for tied positions in top 3' do
        tournament_result.update!(tied: true, position: 2)
        expect(tournament_result.prize_eligible?).to be true
      end

      it 'returns false for tied positions below top 3' do
        tournament_result.update!(tied: true, position: 4)
        expect(tournament_result.prize_eligible?).to be false
      end
    end

    describe '#format_position' do
      it 'returns position as string when not tied' do
        tournament_result.update!(position: 3, tied: false)
        expect(tournament_result.format_position).to eq('3')
      end

      it 'returns T-prefixed position when tied' do
        tournament_result.update!(position: 2, tied: true)
        expect(tournament_result.format_position).to eq('T2')
      end
    end

    describe '#format_to_par' do
      it 'returns E for even par' do
        tournament_result.update!(total_to_par: 0)
        expect(tournament_result.format_to_par).to eq('E')
      end

      it 'returns +N for over par' do
        tournament_result.update!(total_to_par: 3)
        expect(tournament_result.format_to_par).to eq('+3')
      end

      it 'returns -N for under par' do
        tournament_result.update!(total_to_par: -2)
        expect(tournament_result.format_to_par).to eq('-2')
      end
    end

    describe 'delegations' do
      it 'delegates organization to tournament' do
        expect(tournament_result.organization).to eq(tournament.organization)
      end

      it 'delegates user to tournament_entry' do
        expect(tournament_result.user).to eq(tournament_entry.user)
      end

      it 'delegates player_full_name to user' do
        expect(tournament_result.player_full_name).to eq(tournament_entry.user.full_name)
      end
    end
  end
end