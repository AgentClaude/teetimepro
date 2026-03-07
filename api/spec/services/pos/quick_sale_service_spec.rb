require 'rails_helper'

RSpec.describe Pos::QuickSaleService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }
  let(:user) { create(:user, organization: org, role: :staff) }
  let!(:product1) { create(:pos_product, :food, organization: org, course: course, price_cents: 500) }
  let!(:product2) { create(:pos_product, :beverage, organization: org, course: course, price_cents: 350) }

  describe '.call' do
    let(:items) { [{ product_id: product1.id, quantity: 2 }, { product_id: product2.id, quantity: 1 }] }

    context 'with valid inputs' do
      it 'creates a tab with items' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          golfer_name: 'John Doe',
          items: items
        )

        expect(result).to be_success
        tab = result.data[:tab]
        expect(tab.golfer_name).to eq('John Doe')
        expect(tab.fnb_tab_items.count).to eq(2)
        expect(tab.total_cents).to eq(1350) # 500*2 + 350*1
      end
    end

    context 'with inventory tracking' do
      let!(:tracked_product) do
        create(:pos_product, :with_inventory, organization: org, course: course,
               stock_quantity: 5, price_cents: 100)
      end

      it 'decrements stock' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          golfer_name: 'Jane Doe',
          items: [{ product_id: tracked_product.id, quantity: 2 }]
        )

        expect(result).to be_success
        expect(tracked_product.reload.stock_quantity).to eq(3)
      end
    end

    context 'with empty items' do
      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          golfer_name: 'John Doe',
          items: []
        )

        expect(result).not_to be_success
        expect(result.errors).to include('Items must contain at least one item')
      end
    end

    context 'with invalid product' do
      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          golfer_name: 'John Doe',
          items: [{ product_id: 999_999, quantity: 1 }]
        )

        expect(result).not_to be_success
      end
    end

    context 'with inactive product' do
      let!(:inactive) { create(:pos_product, :inactive, organization: org, course: course) }

      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          golfer_name: 'John Doe',
          items: [{ product_id: inactive.id, quantity: 1 }]
        )

        expect(result).not_to be_success
      end
    end

    context 'with wrong organization user' do
      let(:other_org) { create(:organization) }
      let(:other_user) { create(:user, organization: other_org) }

      it 'raises authorization error' do
        expect {
          described_class.call(
            organization: org,
            user: other_user,
            course: course,
            golfer_name: 'John Doe',
            items: items
          )
        }.to raise_error(AuthorizationError)
      end
    end
  end
end
