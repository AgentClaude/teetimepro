require 'rails_helper'

RSpec.describe FnbTabItem, type: :model do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:user) { create(:user, organization: organization) }
  let(:fnb_tab) { create(:fnb_tab, organization: organization, course: course, user: user) }

  describe 'associations' do
    it { should belong_to(:fnb_tab) }
    it { should belong_to(:added_by).class_name('User') }
  end

  describe 'validations' do
    subject { build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_presence_of(:unit_price_cents) }
    it { should validate_numericality_of(:unit_price_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:total_cents) }
    it { should validate_numericality_of(:total_cents).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:category) }
    it { should validate_inclusion_of(:category).in_array(%w[food beverage other]) }

    describe 'total_cents_matches_calculation' do
      it 'is valid when total_cents equals quantity * unit_price_cents' do
        item = build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
                     quantity: 2, unit_price_cents: 1000, total_cents: 2000)
        expect(item).to be_valid
      end

      it 'is invalid when total_cents does not match calculation' do
        item = build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
                     quantity: 2, unit_price_cents: 1000, total_cents: 1500)
        expect(item).not_to be_valid
        expect(item.errors[:total_cents]).to include('should equal quantity (2) × unit price (1000) = 2000')
      end
    end

    describe 'tab_can_be_modified' do
      it 'is invalid when tab is closed' do
        closed_tab = create(:fnb_tab, :closed, organization: organization, course: course, user: user)
        item = build(:fnb_tab_item, fnb_tab: closed_tab, added_by: user)
        
        expect(item).not_to be_valid
        expect(item.errors[:fnb_tab]).to include('cannot be modified once closed or merged')
      end

      it 'is valid when tab is open' do
        item = build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user)
        expect(item).to be_valid
      end
    end

    describe 'organization_consistency' do
      it 'is invalid when added_by user is from different organization' do
        other_org = create(:organization)
        other_user = create(:user, organization: other_org)
        item = build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: other_user)
        
        expect(item).not_to be_valid
        expect(item.errors[:added_by]).to include('must belong to the same organization as the tab')
      end
    end
  end

  describe 'enums' do
    it { should define_enum_for(:category).with_values(food: 'food', beverage: 'beverage', other: 'other') }
  end

  describe 'scopes' do
    let!(:food_item) { create(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user, category: 'food') }
    let!(:beverage_item) { create(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user, category: 'beverage') }

    describe '.for_tab' do
      let(:other_tab) { create(:fnb_tab, organization: organization, course: course, user: user) }
      let!(:other_item) { create(:fnb_tab_item, fnb_tab: other_tab, added_by: user) }

      it 'returns items for the specified tab' do
        items = described_class.for_tab(fnb_tab)
        expect(items).to include(food_item, beverage_item)
        expect(items).not_to include(other_item)
      end
    end

    describe '.by_category' do
      it 'returns items of the specified category' do
        food_items = described_class.by_category('food')
        beverage_items = described_class.by_category('beverage')
        
        expect(food_items).to include(food_item)
        expect(food_items).not_to include(beverage_item)
        
        expect(beverage_items).to include(beverage_item)
        expect(beverage_items).not_to include(food_item)
      end
    end
  end

  describe 'callbacks' do
    describe 'calculate_total_cents' do
      it 'sets total_cents based on quantity and unit_price_cents' do
        item = build(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
                     quantity: 3, unit_price_cents: 500, total_cents: nil)
        expect { item.valid? }.to change { item.total_cents }.to(1500)
      end
    end

    describe 'update_tab_total' do
      it 'updates the tab total when item is created' do
        expect(fnb_tab.total_cents).to eq(0)
        
        create(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
               quantity: 2, unit_price_cents: 1000)
        
        fnb_tab.reload
        expect(fnb_tab.total_cents).to eq(2000)
      end

      it 'updates the tab total when item is destroyed' do
        item = create(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
                      quantity: 2, unit_price_cents: 1000)
        
        fnb_tab.reload
        expect(fnb_tab.total_cents).to eq(2000)
        
        item.destroy
        fnb_tab.reload
        expect(fnb_tab.total_cents).to eq(0)
      end
    end
  end

  describe 'instance methods' do
    let(:item) { create(:fnb_tab_item, fnb_tab: fnb_tab, added_by: user,
                        quantity: 2, unit_price_cents: 1500) }

    describe '#unit_price_amount' do
      it 'returns Money object for unit_price_cents' do
        expect(item.unit_price_amount).to be_a(Money)
        expect(item.unit_price_amount.cents).to eq(1500)
      end
    end

    describe '#total_amount' do
      it 'returns Money object for total_cents' do
        expect(item.total_amount).to be_a(Money)
        expect(item.total_amount.cents).to eq(3000) # 2 * 1500
      end
    end

    describe '#line_total' do
      it 'returns quantity * unit_price_cents' do
        expect(item.line_total).to eq(3000)
      end
    end

    describe '#organization' do
      it 'returns organization through fnb_tab' do
        expect(item.organization).to eq(organization)
      end
    end

    describe '#course' do
      it 'returns course through fnb_tab' do
        expect(item.course).to eq(course)
      end
    end

    describe '#can_be_modified?' do
      it 'delegates to fnb_tab.can_be_modified?' do
        expect(item.can_be_modified?).to eq(fnb_tab.can_be_modified?)
      end
    end
  end
end
