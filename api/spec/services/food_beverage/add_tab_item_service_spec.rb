require 'rails_helper'

RSpec.describe FoodBeverage::AddTabItemService do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:course) { create(:course, organization: organization) }
  let(:fnb_tab) { create(:fnb_tab, organization: organization, course: course, user: user) }

  describe '.call' do
    context 'with valid params' do
      it 'adds item to tab successfully' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Cheeseburger',
          quantity: 2,
          unit_price_cents: 1200,
          category: 'food'
        )

        expect(result).to be_success
        expect(result.item).to be_a(FnbTabItem)
        expect(result.item.name).to eq('Cheeseburger')
        expect(result.item.quantity).to eq(2)
        expect(result.item.unit_price_cents).to eq(1200)
        expect(result.item.total_cents).to eq(2400)
        expect(result.item.category).to eq('food')
        expect(result.item.fnb_tab).to eq(fnb_tab)
        expect(result.item.added_by).to eq(user)
      end

      it 'updates tab total' do
        expect {
          described_class.call(
            organization: organization,
            user: user,
            tab_id: fnb_tab.id,
            name: 'Cheeseburger',
            quantity: 2,
            unit_price_cents: 1200,
            category: 'food'
          )
        }.to change { fnb_tab.reload.total_cents }.from(0).to(2400)
      end

      it 'defaults to food category' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Sandwich',
          quantity: 1,
          unit_price_cents: 800
        )

        expect(result).to be_success
        expect(result.item.category).to eq('food')
      end

      it 'strips whitespace from name' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: '  Cheeseburger  ',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_success
        expect(result.item.name).to eq('Cheeseburger')
      end

      it 'includes notes when provided' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200,
          notes: '  No pickles  '
        )

        expect(result).to be_success
        expect(result.item.notes).to eq('No pickles')
      end

      it 'broadcasts real-time notification' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "fnb_tabs_#{organization.id}",
          hash_including(
            type: 'tab.item_added',
            tab: hash_including(
              id: fnb_tab.id,
              golfer_name: fnb_tab.golfer_name
            ),
            item: hash_including(
              name: 'Cheeseburger',
              quantity: 2,
              unit_price_cents: 1200
            )
          )
        )

        described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Cheeseburger',
          quantity: 2,
          unit_price_cents: 1200
        )
      end
    end

    context 'with invalid params' do
      it 'fails when tab_id is missing' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: nil,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Tab can\'t be blank')
      end

      it 'fails when name is missing' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: '',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Name can\'t be blank')
      end

      it 'fails when quantity is zero' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Burger',
          quantity: 0,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Quantity must be greater than 0')
      end

      it 'fails when unit_price_cents is negative' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: -100
        )

        expect(result).to be_failure
        expect(result.errors).to include('Unit price cents must be greater than or equal to 0')
      end

      it 'fails when category is invalid' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200,
          category: 'invalid'
        )

        expect(result).to be_failure
        expect(result.errors).to include('Category is not included in the list')
      end

      it 'fails when tab does not exist' do
        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: 99999,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Tab not found')
      end

      it 'fails when tab belongs to different organization' do
        other_org = create(:organization)
        other_tab = create(:fnb_tab, organization: other_org)

        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: other_tab.id,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Tab not found')
      end

      it 'fails when tab is closed' do
        fnb_tab.update!(status: 'closed')

        result = described_class.call(
          organization: organization,
          user: user,
          tab_id: fnb_tab.id,
          name: 'Burger',
          quantity: 1,
          unit_price_cents: 1200
        )

        expect(result).to be_failure
        expect(result.errors).to include('Tab cannot be modified')
      end
    end
  end
end