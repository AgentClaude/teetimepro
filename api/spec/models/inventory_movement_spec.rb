require 'rails_helper'

RSpec.describe InventoryMovement, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:product) { create(:pos_product, organization: organization, course: course) }
  let(:user) { create(:user, organization: organization) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:pos_product) }
    it { should belong_to(:course) }
    it { should belong_to(:performed_by).class_name('User') }
    it { should belong_to(:reference).optional }
  end

  describe 'validations' do
    subject { build(:inventory_movement, organization: organization, pos_product: product, course: course, performed_by: user) }

    it { should validate_presence_of(:movement_type) }
    it { should validate_inclusion_of(:movement_type).in_array(%w[receipt sale adjustment transfer_in transfer_out]) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).other_than(0) }
    it { should validate_numericality_of(:unit_cost_cents).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:total_cost_cents).is_greater_than_or_equal_to(0).allow_nil }

    describe 'organization consistency' do
      it 'validates course belongs to organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        movement = build(:inventory_movement, organization: organization, course: other_course, pos_product: product, performed_by: user)

        expect(movement).not_to be_valid
        expect(movement.errors[:course]).to include('must belong to the same organization')
      end

      it 'validates product belongs to organization' do
        other_org = create(:organization)
        other_product = create(:pos_product, organization: other_org)
        movement = build(:inventory_movement, organization: organization, pos_product: other_product, course: course, performed_by: user)

        expect(movement).not_to be_valid
        expect(movement.errors[:pos_product]).to include('must belong to the same organization')
      end
    end

    describe 'quantity direction validation' do
      it 'requires positive quantity for receipts' do
        movement = build(:inventory_movement, movement_type: 'receipt', quantity: -5, organization: organization, pos_product: product, course: course, performed_by: user)
        expect(movement).not_to be_valid
        expect(movement.errors[:quantity]).to include('must be positive for receipts and transfers in')
      end

      it 'requires positive quantity for transfer_in' do
        movement = build(:inventory_movement, movement_type: 'transfer_in', quantity: -3, organization: organization, pos_product: product, course: course, performed_by: user)
        expect(movement).not_to be_valid
        expect(movement.errors[:quantity]).to include('must be positive for receipts and transfers in')
      end

      it 'requires negative quantity for sales' do
        movement = build(:inventory_movement, movement_type: 'sale', quantity: 5, organization: organization, pos_product: product, course: course, performed_by: user)
        expect(movement).not_to be_valid
        expect(movement.errors[:quantity]).to include('must be negative for sales and transfers out')
      end

      it 'requires negative quantity for transfer_out' do
        movement = build(:inventory_movement, movement_type: 'transfer_out', quantity: 2, organization: organization, pos_product: product, course: course, performed_by: user)
        expect(movement).not_to be_valid
        expect(movement.errors[:quantity]).to include('must be negative for sales and transfers out')
      end

      it 'allows positive or negative quantity for adjustments' do
        positive_movement = build(:inventory_movement, movement_type: 'adjustment', quantity: 5, organization: organization, pos_product: product, course: course, performed_by: user)
        negative_movement = build(:inventory_movement, movement_type: 'adjustment', quantity: -3, organization: organization, pos_product: product, course: course, performed_by: user)

        expect(positive_movement).to be_valid
        expect(negative_movement).to be_valid
      end
    end
  end

  describe 'scopes' do
    before do
      create(:inventory_movement, quantity: 10, movement_type: 'receipt', organization: organization, pos_product: product, course: course, performed_by: user)
      create(:inventory_movement, quantity: -5, movement_type: 'sale', organization: organization, pos_product: product, course: course, performed_by: user)
    end

    it 'filters positive movements' do
      expect(InventoryMovement.positive_movements.count).to eq(1)
    end

    it 'filters negative movements' do
      expect(InventoryMovement.negative_movements.count).to eq(1)
    end

    it 'orders by recent' do
      old_movement = create(:inventory_movement, quantity: 2, movement_type: 'adjustment', organization: organization, pos_product: product, course: course, performed_by: user)
      old_movement.update(created_at: 1.week.ago)

      expect(InventoryMovement.recent.first.created_at).to be > old_movement.created_at
    end
  end

  describe 'methods' do
    describe '#positive_quantity?' do
      it 'returns true for positive quantities' do
        movement = build(:inventory_movement, quantity: 5)
        expect(movement.positive_quantity?).to be true
      end

      it 'returns false for negative quantities' do
        movement = build(:inventory_movement, quantity: -5)
        expect(movement.positive_quantity?).to be false
      end
    end

    describe '#negative_quantity?' do
      it 'returns false for positive quantities' do
        movement = build(:inventory_movement, quantity: 5)
        expect(movement.negative_quantity?).to be false
      end

      it 'returns true for negative quantities' do
        movement = build(:inventory_movement, quantity: -5)
        expect(movement.negative_quantity?).to be true
      end
    end

    describe '#formatted_quantity' do
      it 'adds + sign for positive quantities' do
        movement = build(:inventory_movement, quantity: 5)
        expect(movement.formatted_quantity).to eq('+5')
      end

      it 'keeps - sign for negative quantities' do
        movement = build(:inventory_movement, quantity: -5)
        expect(movement.formatted_quantity).to eq('-5')
      end
    end

    describe '#unit_cost_amount' do
      it 'returns Money object when unit_cost_cents is present' do
        movement = build(:inventory_movement, unit_cost_cents: 250)
        expect(movement.unit_cost_amount).to eq(Money.new(250, 'USD'))
      end

      it 'returns nil when unit_cost_cents is nil' do
        movement = build(:inventory_movement, unit_cost_cents: nil)
        expect(movement.unit_cost_amount).to be_nil
      end
    end
  end

  describe 'callbacks' do
    it 'updates inventory level after create' do
      expect(InventoryLevel).to receive(:refresh_for_product!).with(product, course)
      create(:inventory_movement, organization: organization, pos_product: product, course: course, performed_by: user)
    end

    it 'updates inventory level after quantity update' do
      movement = create(:inventory_movement, quantity: 10, organization: organization, pos_product: product, course: course, performed_by: user)
      expect(InventoryLevel).to receive(:refresh_for_product!).with(product, course)
      movement.update(quantity: 15)
    end

    it 'updates inventory level after destroy' do
      movement = create(:inventory_movement, organization: organization, pos_product: product, course: course, performed_by: user)
      expect(InventoryLevel).to receive(:refresh_for_product!).with(product, course)
      movement.destroy
    end
  end
end