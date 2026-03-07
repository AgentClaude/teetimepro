require 'rails_helper'

RSpec.describe TeeSheets::CreateTurnOrderService do
  let(:org) { create(:organization) }
  let(:course) { create(:course, organization: org) }
  let(:user) { create(:user, organization: org, role: :staff) }
  let(:tee_sheet) { create(:tee_sheet, course: course, date: Date.current) }
  let(:tee_time) { create(:tee_time, tee_sheet: tee_sheet, starts_at: Time.current + 2.hours) }
  let(:booking) { create(:booking, tee_time: tee_time, user: user, status: :confirmed) }
  let!(:product1) { create(:pos_product, :food, organization: org, course: course, price_cents: 500) }
  let!(:product2) { create(:pos_product, :beverage, organization: org, course: course, price_cents: 350) }

  let(:items) { [{ product_id: product1.id, quantity: 2 }, { product_id: product2.id, quantity: 1 }] }

  describe '.call' do
    context 'with valid inputs' do
      it 'creates a turn order tab linked to the booking' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items
        )

        expect(result).to be_success
        tab = result.data[:tab]
        expect(tab.turn_order).to be true
        expect(tab.booking).to eq(booking)
        expect(tab.delivery_hole).to eq(10)
        expect(tab.fnb_tab_items.count).to eq(2)
        expect(tab.status).to eq('open')
      end

      it 'uses golfer name from booking players' do
        create(:booking_player, booking: booking, name: 'Tiger Woods')

        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items
        )

        expect(result).to be_success
        expect(result.data[:tab].golfer_name).to eq('Tiger Woods')
      end

      it 'accepts custom delivery hole and notes' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items,
          delivery_hole: 14,
          delivery_notes: 'Extra ketchup please'
        )

        expect(result).to be_success
        tab = result.data[:tab]
        expect(tab.delivery_hole).to eq(14)
        expect(tab.delivery_notes).to eq('Extra ketchup please')
      end
    end

    context 'with checked-in booking' do
      before { booking.update!(status: :checked_in) }

      it 'allows creating a turn order' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items
        )

        expect(result).to be_success
      end
    end

    context 'with cancelled booking' do
      before { booking.update!(status: :cancelled, cancelled_at: Time.current) }

      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items
        )

        expect(result).not_to be_success
        expect(result.errors.join).to include('confirmed or checked in')
      end
    end

    context 'with existing open turn order' do
      before do
        create(:fnb_tab,
               organization: org, course: course, user: user,
               booking: booking, turn_order: true, status: 'open')
      end

      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: items
        )

        expect(result).not_to be_success
        expect(result.errors.join).to include('already has an open turn order')
      end
    end

    context 'with empty items' do
      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: booking.id,
          items: []
        )

        expect(result).not_to be_success
        expect(result.errors.join).to include('at least one item')
      end
    end

    context 'with invalid booking id' do
      it 'returns failure' do
        result = described_class.call(
          organization: org,
          user: user,
          course: course,
          booking_id: 999_999,
          items: items
        )

        expect(result).not_to be_success
        expect(result.errors.join).to include('not found')
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
          booking_id: booking.id,
          items: [{ product_id: tracked_product.id, quantity: 2 }]
        )

        expect(result).to be_success
        expect(tracked_product.reload.stock_quantity).to eq(3)
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
            booking_id: booking.id,
            items: items
          )
        }.to raise_error(AuthorizationError)
      end
    end
  end
end
