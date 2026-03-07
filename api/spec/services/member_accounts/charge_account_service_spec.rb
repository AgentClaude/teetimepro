require 'rails_helper'

RSpec.describe MemberAccounts::ChargeAccountService do
  let(:organization) { create(:organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }
  let(:membership) { create(:membership, organization: organization, user: golfer) }

  describe '.call' do
    let(:valid_params) do
      {
        organization: organization,
        user: staff,
        membership_id: membership.id,
        amount_cents: 25_00,
        charge_type: 'fnb',
        description: 'F&B Tab - Test Golfer'
      }
    end

    context 'with valid params' do
      it 'creates a charge successfully' do
        result = described_class.call(**valid_params)

        expect(result).to be_success
        expect(result.charge).to be_a(MemberAccountCharge)
        expect(result.charge.amount_cents).to eq(25_00)
        expect(result.charge.status).to eq('posted')
        expect(result.charge.posted_at).to be_present
      end

      it 'updates membership balance' do
        expect {
          described_class.call(**valid_params)
        }.to change { membership.reload.account_balance_cents }.by(25_00)
      end

      it 'returns new balance' do
        result = described_class.call(**valid_params)
        expect(result.new_balance_cents).to eq(25_00)
      end
    end

    context 'with invalid params' do
      it 'fails when membership not found' do
        result = described_class.call(**valid_params.merge(membership_id: 999_999))
        expect(result).not_to be_success
        expect(result.errors).to include('Membership not found')
      end

      it 'fails when membership is expired' do
        expired = create(:membership, :expired, organization: organization,
                         user: create(:user, organization: organization))
        result = described_class.call(**valid_params.merge(membership_id: expired.id))
        expect(result).not_to be_success
        expect(result.errors).to include('Membership not found')
      end

      it 'fails when charge exceeds credit limit' do
        membership.update!(credit_limit_cents: 100_00, account_balance_cents: 90_00)
        result = described_class.call(**valid_params.merge(amount_cents: 20_00))
        expect(result).not_to be_success
        expect(result.errors.first).to include('credit limit')
      end

      it 'fails when amount is missing' do
        result = described_class.call(**valid_params.merge(amount_cents: nil))
        expect(result).not_to be_success
      end

      it 'fails with wrong organization' do
        other_org = create(:organization, name: 'Other')
        other_user = create(:user, :staff, organization: other_org)
        result = described_class.call(**valid_params.merge(user: other_user))
        expect(result).not_to be_success
      end
    end

    context 'with optional associations' do
      it 'links to an F&B tab' do
        course = create(:course, organization: organization)
        tab = create(:fnb_tab, organization: organization, course: course, user: staff)

        result = described_class.call(**valid_params.merge(fnb_tab_id: tab.id))
        expect(result).to be_success
        expect(result.charge.fnb_tab).to eq(tab)
      end
    end
  end
end
