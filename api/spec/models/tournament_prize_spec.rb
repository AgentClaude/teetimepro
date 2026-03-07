require 'rails_helper'

RSpec.describe TournamentPrize, type: :model do
  let(:organization) { create(:organization) }
  let(:tournament) { create(:tournament, organization: organization) }

  describe 'associations' do
    it { should belong_to(:tournament) }
    it { should belong_to(:awarded_to).class_name('TournamentEntry').optional }
  end

  describe 'validations' do
    subject { build(:tournament_prize, tournament: tournament) }

    it { should validate_presence_of(:position) }
    it { should validate_numericality_of(:position).is_greater_than(0) }
    it { should validate_presence_of(:description) }
    it { should validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:prize_type) }

    it 'validates position uniqueness within tournament' do
      create(:tournament_prize, tournament: tournament, position: 1)
      duplicate = build(:tournament_prize, tournament: tournament, position: 1)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:position]).to include('already exists for this tournament')
    end

    it 'allows same position in different tournaments' do
      other_tournament = create(:tournament, organization: organization)
      create(:tournament_prize, tournament: tournament, position: 1)
      duplicate = build(:tournament_prize, tournament: other_tournament, position: 1)
      expect(duplicate).to be_valid
    end
  end

  describe 'enums' do
    it { should define_enum_for(:prize_type).with_values(cash: 0, voucher: 1, trophy: 2, merchandise: 3, custom: 4) }
  end

  describe 'scopes' do
    let!(:first_place) { create(:tournament_prize, tournament: tournament, position: 1) }
    let!(:third_place) { create(:tournament_prize, tournament: tournament, position: 3) }
    let!(:second_place) { create(:tournament_prize, tournament: tournament, position: 2) }
    let!(:other_tournament_prize) { create(:tournament_prize, position: 1) }

    describe '.for_tournament' do
      it 'returns prizes for the specified tournament' do
        expect(TournamentPrize.for_tournament(tournament)).to contain_exactly(first_place, second_place, third_place)
      end
    end

    describe '.by_position' do
      it 'orders prizes by position' do
        expect(TournamentPrize.by_position).to eq([first_place, second_place, third_place, other_tournament_prize])
      end
    end

    describe '.awarded and .unawarded' do
      let!(:awarded_prize) { create(:tournament_prize, :awarded, tournament: tournament, position: 4) }

      it 'filters by awarded status' do
        expect(TournamentPrize.awarded).to contain_exactly(awarded_prize)
        expect(TournamentPrize.unawarded).to contain_exactly(first_place, second_place, third_place, other_tournament_prize)
      end
    end
  end

  describe 'methods' do
    let(:tournament_prize) { create(:tournament_prize, tournament: tournament, amount_cents: 50000) }

    describe '#awarded?' do
      it 'returns false when not awarded' do
        expect(tournament_prize.awarded?).to be false
      end

      it 'returns true when awarded' do
        entry = create(:tournament_entry, tournament: tournament)
        tournament_prize.update!(awarded_to: entry)
        expect(tournament_prize.awarded?).to be true
      end
    end

    describe '#cash_prize?' do
      it 'returns true for cash prizes' do
        tournament_prize.update!(prize_type: :cash)
        expect(tournament_prize.cash_prize?).to be true
      end

      it 'returns false for non-cash prizes' do
        tournament_prize.update!(prize_type: :trophy)
        expect(tournament_prize.cash_prize?).to be false
      end
    end

    describe '#amount' do
      it 'returns Money object with correct amount' do
        amount = tournament_prize.amount
        expect(amount).to be_a(Money)
        expect(amount.cents).to eq(50000)
        expect(amount.currency.code).to eq('USD')
      end
    end

    describe '#organization delegation' do
      it 'delegates to tournament' do
        expect(tournament_prize.organization).to eq(tournament.organization)
      end
    end
  end
end