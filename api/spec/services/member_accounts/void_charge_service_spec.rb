require 'rails_helper'

RSpec.describe MemberAccounts::VoidChargeService do
  let(:organization) { create(:organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:golfer) { create(:user, organization: organization) }
  let(:membership) { create(:membership, organization: organization, user: golfer) }
  let!(:charge) do
    create(:member_account_charge, organization: organization,
           membership: membership, charged_by: staff, amount_cents: 50_00)
  end

  describe '.call' do
    let(:valid_params) do
      {
        organization: organization,
        user: staff,
        charge_id: charge.id,
        reason: 'Customer complaint'
      }
    end

    context 'with valid params' do
      it 'voids the charge successfully' do
        result = described_class.call(**valid_params)

        expect(result).to be_success
        expect(result.charge.status).to eq('voided')
        expect(result.charge.voided_at).to be_present
      end

      it 'decrements membership balance' do
        expect {
          described_class.call(**valid_params)
        }.to change { membership.reload.account_balance_cents }.by(-50_00)
      end

      it 'appends void reason to notes' do
        result = described_class.call(**valid_params)
        expect(result.charge.notes).to include('Customer complaint')
        expect(result.charge.notes).to include(staff.full_name)
      end
    end

    context 'with invalid params' do
      it 'fails when charge not found' do
        result = described_class.call(**valid_params.merge(charge_id: 999_999))
        expect(result).not_to be_success
        expect(result.errors).to include('Charge not found')
      end

      it 'fails when charge already voided' do
        charge.update!(status: 'voided', voided_at: Time.current)
        result = described_class.call(**valid_params)
        expect(result).not_to be_success
        expect(result.errors).to include('Charge cannot be voided')
      end
    end
  end
end
