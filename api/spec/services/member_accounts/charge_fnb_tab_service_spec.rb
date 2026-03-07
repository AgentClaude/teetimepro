require 'rails_helper'

RSpec.describe MemberAccounts::ChargeFnbTabService do
  let(:organization) { create(:organization) }
  let(:course) { create(:course, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }
  let(:membership) { create(:membership, organization: organization, user: golfer) }
  let(:tab) do
    create(:fnb_tab, organization: organization, course: course, user: staff,
           golfer_name: golfer.full_name, status: 'open')
  end

  before do
    create(:fnb_tab_item, fnb_tab: tab, name: 'Burger', quantity: 1,
           unit_price_cents: 15_00, total_cents: 15_00, added_by: staff)
    create(:fnb_tab_item, fnb_tab: tab, name: 'Beer', quantity: 2,
           unit_price_cents: 8_00, total_cents: 16_00, added_by: staff, category: 'beverage')
  end

  describe '.call' do
    let(:valid_params) do
      {
        organization: organization,
        user: staff,
        tab_id: tab.id,
        membership_id: membership.id
      }
    end

    context 'with valid params' do
      it 'closes the tab and creates a charge' do
        result = described_class.call(**valid_params)

        expect(result).to be_success
        expect(result.fnb_tab.status).to eq('closed')
        expect(result.fnb_tab.closed_at).to be_present
        expect(result.charge.amount_cents).to eq(31_00) # 15 + 16
        expect(result.charge.charge_type).to eq('fnb')
        expect(result.charge.fnb_tab).to eq(tab)
      end

      it 'updates membership balance' do
        expect {
          described_class.call(**valid_params)
        }.to change { membership.reload.account_balance_cents }.by(31_00)
      end

      it 'generates description with item count' do
        result = described_class.call(**valid_params)
        expect(result.charge.description).to include(tab.golfer_name)
        expect(result.charge.description).to include('items')
      end
    end

    context 'with invalid state' do
      it 'fails when tab is already closed' do
        tab.update!(status: 'closed', closed_at: Time.current)
        result = described_class.call(**valid_params)
        expect(result).not_to be_success
        expect(result.errors).to include('Tab is already closed')
      end

      it 'fails when tab has no items' do
        empty_tab = create(:fnb_tab, organization: organization, course: course,
                           user: staff, golfer_name: 'Empty Tab')
        result = described_class.call(**valid_params.merge(tab_id: empty_tab.id))
        expect(result).not_to be_success
        expect(result.errors).to include('Tab has no items')
      end

      it 'fails when charge exceeds credit limit' do
        membership.update!(credit_limit_cents: 20_00)
        result = described_class.call(**valid_params)
        expect(result).not_to be_success
        expect(result.errors.first).to include('exceeds available credit')
      end

      it 'rolls back tab close on charge failure' do
        membership.update!(credit_limit_cents: 20_00)
        described_class.call(**valid_params)
        expect(tab.reload.status).to eq('open')
      end
    end
  end
end
