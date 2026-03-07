require 'rails_helper'

RSpec.describe Tournaments::DefinePrizesService, type: :service do
  let(:organization) { create(:organization) }
  let(:tournament) { create(:tournament, organization: organization, status: :registration_open) }
  
  let(:valid_prize_definitions) do
    [
      { position: 1, prize_type: 'cash', description: 'First Place', amount_cents: 50000 },
      { position: 2, prize_type: 'cash', description: 'Second Place', amount_cents: 25000 },
      { position: 3, prize_type: 'trophy', description: 'Third Place Trophy', amount_cents: 0 }
    ]
  end

  describe '.call' do
    context 'with valid parameters' do
      let(:service) { described_class.new(tournament: tournament, prize_definitions: valid_prize_definitions) }

      it 'creates prizes successfully' do
        result = service.call
        
        expect(result).to be_success
        expect(result.data[:prizes]).to have(3).items
        
        prizes = tournament.tournament_prizes.reload
        expect(prizes.count).to eq(3)
        
        first_place = prizes.find_by(position: 1)
        expect(first_place.prize_type).to eq('cash')
        expect(first_place.description).to eq('First Place')
        expect(first_place.amount_cents).to eq(50000)
      end

      it 'replaces existing prizes' do
        create(:tournament_prize, tournament: tournament, position: 1, description: 'Old Prize')
        
        result = service.call
        
        expect(result).to be_success
        expect(tournament.tournament_prizes.reload.count).to eq(3)
        expect(tournament.tournament_prizes.find_by(description: 'Old Prize')).to be_nil
        expect(tournament.tournament_prizes.find_by(description: 'First Place')).to be_present
      end
    end

    context 'with invalid tournament status' do
      let(:completed_tournament) { create(:tournament, :completed, organization: organization) }
      let(:service) { described_class.new(tournament: completed_tournament, prize_definitions: valid_prize_definitions) }

      it 'fails for completed tournament' do
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament cannot have prizes modified when completed or cancelled')
      end
    end

    context 'with cancelled tournament' do
      let(:cancelled_tournament) { create(:tournament, organization: organization, status: :cancelled) }
      let(:service) { described_class.new(tournament: cancelled_tournament, prize_definitions: valid_prize_definitions) }

      it 'fails for cancelled tournament' do
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament cannot have prizes modified when completed or cancelled')
      end
    end

    context 'with missing parameters' do
      it 'fails without tournament' do
        service = described_class.new(prize_definitions: valid_prize_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Tournament can\'t be blank')
      end

      it 'fails without prize_definitions' do
        service = described_class.new(tournament: tournament)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions can\'t be blank')
      end
    end

    context 'with invalid prize definitions' do
      it 'fails with non-array prize_definitions' do
        service = described_class.new(tournament: tournament, prize_definitions: 'not an array')
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions must be an array of hashes')
      end

      it 'fails with missing position' do
        invalid_definitions = [{ prize_type: 'cash', description: 'First Place', amount_cents: 50000 }]
        service = described_class.new(tournament: tournament, prize_definitions: invalid_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions position must be a positive integer at index 0')
      end

      it 'fails with invalid position' do
        invalid_definitions = [{ position: 0, prize_type: 'cash', description: 'First Place', amount_cents: 50000 }]
        service = described_class.new(tournament: tournament, prize_definitions: invalid_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions position must be a positive integer at index 0')
      end

      it 'fails with invalid prize_type' do
        invalid_definitions = [{ position: 1, prize_type: 'invalid', description: 'First Place', amount_cents: 50000 }]
        service = described_class.new(tournament: tournament, prize_definitions: invalid_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions prize_type must be valid at index 0')
      end

      it 'fails with missing description' do
        invalid_definitions = [{ position: 1, prize_type: 'cash', amount_cents: 50000 }]
        service = described_class.new(tournament: tournament, prize_definitions: invalid_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions description is required at index 0')
      end

      it 'fails with invalid amount_cents' do
        invalid_definitions = [{ position: 1, prize_type: 'cash', description: 'First Place', amount_cents: -100 }]
        service = described_class.new(tournament: tournament, prize_definitions: invalid_definitions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions amount_cents must be a non-negative integer at index 0')
      end

      it 'fails with duplicate positions' do
        duplicate_positions = [
          { position: 1, prize_type: 'cash', description: 'First Place', amount_cents: 50000 },
          { position: 1, prize_type: 'trophy', description: 'Also First Place', amount_cents: 0 }
        ]
        service = described_class.new(tournament: tournament, prize_definitions: duplicate_positions)
        result = service.call
        
        expect(result).to be_failure
        expect(result.errors).to include('Prize definitions cannot have duplicate positions')
      end
    end

    context 'with valid edge cases' do
      it 'allows zero amount_cents' do
        trophy_definitions = [{ position: 1, prize_type: 'trophy', description: 'Winner Trophy', amount_cents: 0 }]
        service = described_class.new(tournament: tournament, prize_definitions: trophy_definitions)
        result = service.call
        
        expect(result).to be_success
        prize = result.data[:prizes].first
        expect(prize.amount_cents).to eq(0)
      end

      it 'works with empty array' do
        service = described_class.new(tournament: tournament, prize_definitions: [])
        result = service.call
        
        expect(result).to be_success
        expect(result.data[:prizes]).to be_empty
        expect(tournament.tournament_prizes.reload.count).to eq(0)
      end

      it 'handles string prize_types correctly' do
        string_type_definitions = [{ position: 1, prize_type: 'cash', description: 'First Place', amount_cents: 50000 }]
        service = described_class.new(tournament: tournament, prize_definitions: string_type_definitions)
        result = service.call
        
        expect(result).to be_success
        prize = result.data[:prizes].first
        expect(prize.prize_type).to eq('cash')
      end
    end
  end
end