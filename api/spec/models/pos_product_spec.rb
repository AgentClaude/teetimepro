require 'rails_helper'

RSpec.describe PosProduct, type: :model do
  subject { build(:pos_product) }

  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:course) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:sku) }
    it { is_expected.to validate_presence_of(:price_cents) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }

    it 'validates uniqueness of sku within organization' do
      existing = create(:pos_product)
      duplicate = build(:pos_product, organization: existing.organization, sku: existing.sku)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:sku]).to be_present
    end

    it 'validates uniqueness of barcode within organization' do
      existing = create(:pos_product, barcode: '12345678')
      duplicate = build(:pos_product, organization: existing.organization, barcode: '12345678')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:barcode]).to be_present
    end

    it 'allows nil barcode' do
      product = build(:pos_product, barcode: nil)
      expect(product).to be_valid
    end

    it 'validates category inclusion' do
      expect(build(:pos_product, category: 'food')).to be_valid
      expect(build(:pos_product, category: 'invalid')).not_to be_valid
    end

    it 'validates organization consistency' do
      other_org = create(:organization)
      course = create(:course) # belongs to its own org
      product = build(:pos_product, organization: other_org, course: course)
      expect(product).not_to be_valid
      expect(product.errors[:course]).to be_present
    end
  end

  describe 'scopes' do
    let!(:org) { create(:organization) }
    let!(:course) { create(:course, organization: org) }
    let!(:active_food) { create(:pos_product, :food, organization: org, course: course, name: 'Hot Dog') }
    let!(:inactive) { create(:pos_product, :inactive, organization: org, course: course) }

    it '.active returns only active products' do
      expect(PosProduct.active).to include(active_food)
      expect(PosProduct.active).not_to include(inactive)
    end

    it '.by_category filters by category' do
      expect(PosProduct.by_category('food')).to include(active_food)
    end

    it '.search finds by name, sku, or barcode' do
      expect(PosProduct.search('Hot Dog')).to include(active_food)
      expect(PosProduct.search(active_food.sku)).to include(active_food)
    end
  end

  describe '#in_stock?' do
    it 'returns true when inventory is not tracked' do
      product = build(:pos_product, track_inventory: false)
      expect(product.in_stock?).to be true
    end

    it 'returns true when tracked and has stock' do
      product = build(:pos_product, :with_inventory, stock_quantity: 10)
      expect(product.in_stock?).to be true
    end

    it 'returns false when tracked and out of stock' do
      product = build(:pos_product, :out_of_stock)
      expect(product.in_stock?).to be false
    end
  end

  describe '#decrement_stock!' do
    it 'decrements stock when tracking inventory' do
      product = create(:pos_product, :with_inventory, stock_quantity: 10)
      product.decrement_stock!(3)
      expect(product.reload.stock_quantity).to eq(7)
    end

    it 'raises when insufficient stock' do
      product = create(:pos_product, :with_inventory, stock_quantity: 1)
      expect { product.decrement_stock!(5) }.to raise_error(RuntimeError, 'Insufficient stock')
    end

    it 'does nothing when not tracking inventory' do
      product = create(:pos_product, track_inventory: false)
      expect { product.decrement_stock! }.not_to raise_error
    end
  end

  describe '#formatted_price' do
    it 'formats cents to dollars' do
      product = build(:pos_product, price_cents: 1250)
      expect(product.formatted_price).to eq('$12.5')
    end
  end
end
