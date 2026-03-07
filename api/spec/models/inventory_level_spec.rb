require 'rails_helper'

RSpec.describe InventoryLevel, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:product) { create(:pos_product, organization: organization, course: course) }

  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:pos_product) }
    it { should belong_to(:course) }
    it { should belong_to(:last_counted_by).class_name('User').optional }
  end

  describe 'validations' do
    subject { build(:inventory_level, organization: organization, pos_product: product, course: course) }

    it { should validate_presence_of(:current_stock) }
    it { should validate_numericality_of(:current_stock).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:reserved_stock) }
    it { should validate_numericality_of(:reserved_stock).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:reorder_point) }
    it { should validate_numericality_of(:reorder_point).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:reorder_quantity) }
    it { should validate_numericality_of(:reorder_quantity).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:average_cost_cents).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:last_cost_cents).is_greater_than_or_equal_to(0).allow_nil }

    describe 'organization consistency' do
      it 'validates course belongs to organization' do
        other_org = create(:organization)
        other_course = create(:course, organization: other_org)
        level = build(:inventory_level, organization: organization, course: other_course, pos_product: product)

        expect(level).not_to be_valid
        expect(level.errors[:course]).to include('must belong to the same organization')
      end

      it 'validates product belongs to organization' do
        other_org = create(:organization)
        other_product = create(:pos_product, organization: other_org)
        level = build(:inventory_level, organization: organization, pos_product: other_product, course: course)

        expect(level).not_to be_valid
        expect(level.errors[:pos_product]).to include('must belong to the same organization')
      end
    end

    describe 'uniqueness per product and course' do
      it 'prevents duplicate inventory levels for same product and course' do
        create(:inventory_level, organization: organization, pos_product: product, course: course)
        duplicate = build(:inventory_level, organization: organization, pos_product: product, course: course)

        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:base]).to include('Inventory level already exists for this product and course')
      end
    end
  end

  describe 'scopes' do
    let(:course2) { create(:course, organization: organization) }
    let(:product2) { create(:pos_product, organization: organization, course: course2) }

    before do
      create(:inventory_level, current_stock: 10, reorder_point: 5, organization: organization, pos_product: product, course: course)
      create(:inventory_level, current_stock: 3, reorder_point: 5, organization: organization, pos_product: product2, course: course2)
      create(:inventory_level, current_stock: 0, reorder_point: 2, organization: organization, pos_product: product, course: course2)
    end

    it 'filters low stock items' do
      expect(InventoryLevel.low_stock.count).to eq(2)
    end

    it 'filters out of stock items' do
      expect(InventoryLevel.out_of_stock.count).to eq(1)
    end

    it 'filters items with stock' do
      expect(InventoryLevel.with_stock.count).to eq(2)
    end

    it 'filters by course' do
      expect(InventoryLevel.for_course(course).count).to eq(1)
    end
  end

  describe '#available_stock' do
    it 'calculates available stock correctly' do
      level = build(:inventory_level, current_stock: 10, reserved_stock: 3)
      expect(level.available_stock).to eq(7)
    end
  end

  describe '#needs_reorder?' do
    it 'returns true when current stock is at reorder point' do
      level = build(:inventory_level, current_stock: 5, reorder_point: 5)
      expect(level.needs_reorder?).to be true
    end

    it 'returns true when current stock is below reorder point' do
      level = build(:inventory_level, current_stock: 3, reorder_point: 5)
      expect(level.needs_reorder?).to be true
    end

    it 'returns false when current stock is above reorder point' do
      level = build(:inventory_level, current_stock: 10, reorder_point: 5)
      expect(level.needs_reorder?).to be false
    end
  end

  describe '#stock_value_cents' do
    it 'calculates stock value correctly' do
      level = build(:inventory_level, current_stock: 10, average_cost_cents: 250)
      expect(level.stock_value_cents).to eq(2500.0)
    end

    it 'returns 0 when no average cost' do
      level = build(:inventory_level, current_stock: 10, average_cost_cents: nil)
      expect(level.stock_value_cents).to eq(0)
    end

    it 'returns 0 when no current stock' do
      level = build(:inventory_level, current_stock: 0, average_cost_cents: 250)
      expect(level.stock_value_cents).to eq(0)
    end
  end

  describe '#stock_value_amount' do
    it 'returns Money object for stock value' do
      level = build(:inventory_level, current_stock: 10, average_cost_cents: 250)
      expect(level.stock_value_amount).to eq(Money.new(2500, 'USD'))
    end
  end

  describe '#stock_status' do
    it 'returns out_of_stock when current stock is 0' do
      level = build(:inventory_level, current_stock: 0, reorder_point: 5)
      expect(level.stock_status).to eq('out_of_stock')
    end

    it 'returns low_stock when needs reorder' do
      level = build(:inventory_level, current_stock: 3, reorder_point: 5)
      expect(level.stock_status).to eq('low_stock')
    end

    it 'returns in_stock when above reorder point' do
      level = build(:inventory_level, current_stock: 10, reorder_point: 5)
      expect(level.stock_status).to eq('in_stock')
    end
  end

  describe '.refresh_for_product!' do
    let(:user) { create(:user, organization: organization) }

    before do
      # Create some movements
      create(:inventory_movement, quantity: 10, movement_type: 'receipt', unit_cost_cents: 200, 
             organization: organization, pos_product: product, course: course, performed_by: user)
      create(:inventory_movement, quantity: 5, movement_type: 'receipt', unit_cost_cents: 300, 
             organization: organization, pos_product: product, course: course, performed_by: user)
      create(:inventory_movement, quantity: -3, movement_type: 'sale', 
             organization: organization, pos_product: product, course: course, performed_by: user)
    end

    it 'creates inventory level if it does not exist' do
      expect {
        InventoryLevel.refresh_for_product!(product, course)
      }.to change(InventoryLevel, :count).by(1)
    end

    it 'updates existing inventory level' do
      level = create(:inventory_level, organization: organization, pos_product: product, course: course, current_stock: 0)
      
      InventoryLevel.refresh_for_product!(product, course)
      level.reload
      
      expect(level.current_stock).to eq(12) # 10 + 5 - 3
    end

    it 'calculates average cost correctly' do
      InventoryLevel.refresh_for_product!(product, course)
      level = InventoryLevel.find_by(pos_product: product, course: course)
      
      # Weighted average: (10 * 200 + 5 * 300) / 15 = 233.33
      expect(level.average_cost_cents).to eq(233.33)
    end

    it 'sets last cost from most recent receipt' do
      InventoryLevel.refresh_for_product!(product, course)
      level = InventoryLevel.find_by(pos_product: product, course: course)
      
      expect(level.last_cost_cents).to eq(300) # Most recent receipt
    end

    it 'handles negative stock by setting to 0' do
      create(:inventory_movement, quantity: -20, movement_type: 'adjustment', 
             organization: organization, pos_product: product, course: course, performed_by: user)
      
      InventoryLevel.refresh_for_product!(product, course)
      level = InventoryLevel.find_by(pos_product: product, course: course)
      
      expect(level.current_stock).to eq(0) # Can't go below 0
    end
  end
end