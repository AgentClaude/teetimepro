require 'rails_helper'

RSpec.describe LoyaltyAccount, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:user) }
    it { should have_many(:loyalty_transactions).dependent(:destroy) }
    it { should have_many(:loyalty_redemptions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:loyalty_account) }
    
    it { should validate_presence_of(:points_balance) }
    it { should validate_presence_of(:lifetime_points) }
    it { should validate_numericality_of(:points_balance).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:lifetime_points).is_greater_than_or_equal_to(0) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:organization_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:tier).with_values(bronze: 0, silver: 1, gold: 2, platinum: 3) }
  end

  describe 'scopes' do
    let(:organization) { create(:organization) }
    let(:other_org) { create(:organization) }
    
    before do
      create(:loyalty_account, organization: organization, tier: :bronze)
      create(:loyalty_account, organization: organization, tier: :silver)
      create(:loyalty_account, organization: other_org, tier: :gold)
    end

    describe '.for_organization' do
      it 'returns accounts for the specified organization' do
        result = described_class.for_organization(organization)
        expect(result.count).to eq(2)
        expect(result.pluck(:organization_id)).to all(eq(organization.id))
      end
    end

    describe '.by_tier' do
      it 'returns accounts with the specified tier' do
        result = described_class.by_tier(:silver)
        expect(result.count).to eq(1)
        expect(result.first.tier).to eq('silver')
      end
    end
  end

  describe '#loyalty_program' do
    let(:organization) { create(:organization) }
    let(:loyalty_program) { create(:loyalty_program, organization: organization) }
    let(:account) { create(:loyalty_account, organization: organization) }

    it 'returns the active loyalty program for the organization' do
      expect(account.loyalty_program).to eq(loyalty_program)
    end

    it 'returns nil if no active loyalty program' do
      loyalty_program.update!(is_active: false)
      expect(account.loyalty_program).to be_nil
    end
  end

  describe '#can_afford?' do
    let(:account) { create(:loyalty_account, points_balance: 500) }

    it 'returns true if account has enough points' do
      expect(account.can_afford?(300)).to be true
    end

    it 'returns true if account has exactly enough points' do
      expect(account.can_afford?(500)).to be true
    end

    it 'returns false if account does not have enough points' do
      expect(account.can_afford?(600)).to be false
    end
  end

  describe '#add_points!' do
    let(:account) { create(:loyalty_account, points_balance: 100, lifetime_points: 200) }

    it 'adds points to both current and lifetime balances for positive amounts' do
      account.add_points!(50, description: 'Test earning')
      
      account.reload
      expect(account.points_balance).to eq(150)
      expect(account.lifetime_points).to eq(250)
    end

    it 'creates a transaction record' do
      expect {
        account.add_points!(50, description: 'Test earning')
      }.to change(account.loyalty_transactions, :count).by(1)

      transaction = account.loyalty_transactions.last
      expect(transaction.transaction_type).to eq('earn')
      expect(transaction.points).to eq(50)
      expect(transaction.description).to eq('Test earning')
      expect(transaction.balance_after).to eq(150)
    end

    it 'updates tier if threshold is crossed' do
      # Assume tier thresholds: silver: 500, gold: 2000, platinum: 5000
      loyalty_program = create(:loyalty_program, organization: account.organization)
      
      account.update!(lifetime_points: 450)
      account.add_points!(100, description: 'Tier upgrade')
      
      account.reload
      expect(account.tier).to eq('silver')
    end

    it 'accepts a source object' do
      booking = create(:booking, user: account.user)
      
      account.add_points!(50, description: 'Booking reward', source: booking)
      
      transaction = account.loyalty_transactions.last
      expect(transaction.source).to eq(booking)
    end
  end

  describe '#deduct_points!' do
    let(:account) { create(:loyalty_account, points_balance: 500) }

    it 'deducts points from current balance' do
      account.deduct_points!(100, description: 'Test redemption')
      
      account.reload
      expect(account.points_balance).to eq(400)
      expect(account.lifetime_points).to eq(250) # unchanged
    end

    it 'creates a redemption transaction record' do
      expect {
        account.deduct_points!(100, description: 'Test redemption')
      }.to change(account.loyalty_transactions, :count).by(1)

      transaction = account.loyalty_transactions.last
      expect(transaction.transaction_type).to eq('redeem')
      expect(transaction.points).to eq(-100)
      expect(transaction.description).to eq('Test redemption')
      expect(transaction.balance_after).to eq(400)
    end

    it 'raises error if insufficient points' do
      expect {
        account.deduct_points!(600, description: 'Too expensive')
      }.to raise_error(ArgumentError, 'Insufficient points')
    end
  end

  describe '#adjust_points!' do
    let(:account) { create(:loyalty_account, points_balance: 100, lifetime_points: 200) }

    it 'adjusts points for positive amounts' do
      account.adjust_points!(25, description: 'Admin adjustment')
      
      account.reload
      expect(account.points_balance).to eq(125)
      expect(account.lifetime_points).to eq(225)
    end

    it 'adjusts points for negative amounts' do
      account.adjust_points!(-25, description: 'Admin correction')
      
      account.reload
      expect(account.points_balance).to eq(75)
      expect(account.lifetime_points).to eq(200) # unchanged for negative
    end

    it 'creates an adjustment transaction record' do
      expect {
        account.adjust_points!(25, description: 'Admin adjustment')
      }.to change(account.loyalty_transactions, :count).by(1)

      transaction = account.loyalty_transactions.last
      expect(transaction.transaction_type).to eq('adjust')
      expect(transaction.points).to eq(25)
    end
  end

  describe '#recent_transactions' do
    let(:account) { create(:loyalty_account) }

    before do
      11.times do |i|
        create(:loyalty_transaction, 
               loyalty_account: account, 
               created_at: i.hours.ago)
      end
    end

    it 'returns the most recent 10 transactions by default' do
      expect(account.recent_transactions.count).to eq(10)
    end

    it 'orders transactions by creation date descending' do
      transactions = account.recent_transactions
      expect(transactions.first.created_at).to be > transactions.last.created_at
    end

    it 'accepts a custom limit' do
      expect(account.recent_transactions(limit: 5).count).to eq(5)
    end
  end

  describe '#tier_name' do
    it 'returns humanized tier name' do
      account = create(:loyalty_account, tier: :silver)
      expect(account.tier_name).to eq('Silver')
    end
  end

  describe '#points_needed_for_next_tier' do
    let(:organization) { create(:organization) }
    let!(:loyalty_program) { create(:loyalty_program, organization: organization) }
    
    it 'returns points needed for silver tier from bronze' do
      account = create(:loyalty_account, organization: organization, lifetime_points: 200)
      expect(account.points_needed_for_next_tier).to eq(300) # 500 - 200
    end

    it 'returns 0 for platinum tier (highest tier)' do
      account = create(:loyalty_account, organization: organization, lifetime_points: 6000, tier: :platinum)
      expect(account.points_needed_for_next_tier).to eq(0)
    end

    it 'returns 0 if no loyalty program exists' do
      account = create(:loyalty_account, lifetime_points: 200)
      expect(account.points_needed_for_next_tier).to eq(0)
    end
  end
end