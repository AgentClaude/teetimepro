require 'rails_helper'

RSpec.describe MemberAccountCharge, type: :model do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, organization: organization) }
  let(:staff) { create(:user, :staff, organization: organization) }
  let(:membership) { create(:membership, organization: organization, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:membership) }
    it { is_expected.to belong_to(:charged_by).class_name('User') }
    it { is_expected.to belong_to(:fnb_tab).optional }
    it { is_expected.to belong_to(:booking).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount_cents) }
    it { is_expected.to validate_presence_of(:charge_type) }
    it { is_expected.to validate_presence_of(:description) }

    it 'requires amount_cents > 0' do
      charge = build(:member_account_charge, organization: organization,
                     membership: membership, charged_by: staff, amount_cents: 0)
      expect(charge).not_to be_valid
      expect(charge.errors[:amount_cents]).to be_present
    end

    it 'validates organization consistency' do
      other_org = create(:organization, name: 'Other Org')
      other_membership = create(:membership, organization: other_org,
                                user: create(:user, organization: other_org))
      charge = build(:member_account_charge, organization: organization,
                     membership: other_membership, charged_by: staff)
      expect(charge).not_to be_valid
      expect(charge.errors[:membership]).to include('must belong to the same organization')
    end

    it 'validates membership is active' do
      expired_membership = create(:membership, :expired, organization: organization,
                                  user: create(:user, organization: organization))
      charge = build(:member_account_charge, organization: organization,
                     membership: expired_membership, charged_by: staff)
      expect(charge).not_to be_valid
      expect(charge.errors[:membership]).to include('must be active to accept charges')
    end
  end

  describe 'enums' do
    it 'defines charge_type enum' do
      expect(described_class.charge_types).to include(
        'fnb' => 'fnb',
        'booking' => 'booking',
        'pro_shop' => 'pro_shop',
        'dues' => 'dues',
        'other' => 'other'
      )
    end

    it 'defines status enum' do
      expect(described_class.statuses).to include(
        'pending' => 'pending',
        'posted' => 'posted',
        'voided' => 'voided',
        'paid' => 'paid'
      )
    end
  end

  describe 'scopes' do
    let!(:posted_charge) do
      create(:member_account_charge, organization: organization,
             membership: membership, charged_by: staff, status: 'posted')
    end
    let!(:voided_charge) do
      create(:member_account_charge, :voided, organization: organization,
             membership: membership, charged_by: staff)
    end

    it '.outstanding returns pending and posted charges' do
      expect(described_class.outstanding).to include(posted_charge)
      expect(described_class.outstanding).not_to include(voided_charge)
    end

    it '.for_organization scopes to org' do
      expect(described_class.for_organization(organization)).to include(posted_charge)
    end
  end

  describe '#voidable?' do
    it 'returns true for pending charges' do
      charge = build(:member_account_charge, :pending)
      expect(charge.voidable?).to be true
    end

    it 'returns true for posted charges' do
      charge = build(:member_account_charge, status: 'posted')
      expect(charge.voidable?).to be true
    end

    it 'returns false for voided charges' do
      charge = build(:member_account_charge, :voided)
      expect(charge.voidable?).to be false
    end
  end

  describe 'balance updates' do
    it 'increments membership balance on create' do
      expect {
        create(:member_account_charge, organization: organization,
               membership: membership, charged_by: staff, amount_cents: 50_00)
      }.to change { membership.reload.account_balance_cents }.by(50_00)
    end

    it 'decrements membership balance when voided' do
      charge = create(:member_account_charge, organization: organization,
                      membership: membership, charged_by: staff, amount_cents: 50_00)

      expect {
        charge.update!(status: 'voided', voided_at: Time.current)
      }.to change { membership.reload.account_balance_cents }.by(-50_00)
    end
  end
end
