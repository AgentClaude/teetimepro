require 'rails_helper'

RSpec.describe LoyaltyTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:loyalty_account) }
    it { should belong_to(:source).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:points) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:balance_after) }
    it { should validate_numericality_of(:balance_after).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:transaction_type).with_values(earn: 0, redeem: 1, adjust: 2, expire: 3) }
  end

  describe 'scopes' do
    let(:account) { create(:loyalty_account) }
    let(:other_account) { create(:loyalty_account) }

    before do
      create(:loyalty_transaction, :earning, loyalty_account: account, created_at: 2.hours.ago)
      create(:loyalty_transaction, :redemption, loyalty_account: account, created_at: 1.hour.ago)
      create(:loyalty_transaction, :adjustment, loyalty_account: other_account, created_at: 30.minutes.ago)
      create(:loyalty_transaction, :expiration, loyalty_account: account, created_at: 10.minutes.ago)
    end

    describe '.for_account' do
      it 'returns transactions for the specified account' do
        result = described_class.for_account(account)
        expect(result.count).to eq(3)
        expect(result.pluck(:loyalty_account_id)).to all(eq(account.id))
      end
    end

    describe '.recent' do
      it 'orders transactions by creation date descending' do
        result = described_class.recent
        created_at_times = result.pluck(:created_at)
        expect(created_at_times).to eq(created_at_times.sort.reverse)
      end
    end

    describe '.by_type' do
      it 'returns transactions of the specified type' do
        result = described_class.by_type(:earn)
        expect(result.count).to eq(1)
        expect(result.first.transaction_type).to eq('earn')
      end
    end
  end

  describe '#points_display' do
    it 'shows positive points with + for earning' do
      transaction = build(:loyalty_transaction, :earning, points: 100)
      expect(transaction.points_display).to eq('+100')
    end

    it 'shows negative points with - for redemption' do
      transaction = build(:loyalty_transaction, :redemption, points: -200)
      expect(transaction.points_display).to eq('-200')
    end

    it 'shows positive points with + for positive adjustment' do
      transaction = build(:loyalty_transaction, :adjustment, points: 50)
      expect(transaction.points_display).to eq('+50')
    end

    it 'shows negative points as-is for negative adjustment' do
      transaction = build(:loyalty_transaction, :adjustment, points: -25)
      expect(transaction.points_display).to eq('-25')
    end

    it 'shows negative points with - for expiration' do
      transaction = build(:loyalty_transaction, :expiration, points: -100)
      expect(transaction.points_display).to eq('-100')
    end
  end

  describe '#transaction_icon' do
    it 'returns + for earning' do
      transaction = build(:loyalty_transaction, :earning)
      expect(transaction.transaction_icon).to eq('+')
    end

    it 'returns - for redemption' do
      transaction = build(:loyalty_transaction, :redemption)
      expect(transaction.transaction_icon).to eq('-')
    end

    it 'returns + for positive adjustment' do
      transaction = build(:loyalty_transaction, :adjustment, points: 50)
      expect(transaction.transaction_icon).to eq('+')
    end

    it 'returns - for negative adjustment' do
      transaction = build(:loyalty_transaction, :adjustment, points: -25)
      expect(transaction.transaction_icon).to eq('-')
    end

    it 'returns warning symbol for expiration' do
      transaction = build(:loyalty_transaction, :expiration)
      expect(transaction.transaction_icon).to eq('⚠')
    end
  end

  describe '#positive?' do
    it 'returns true for positive points' do
      transaction = build(:loyalty_transaction, points: 100)
      expect(transaction.positive?).to be true
    end

    it 'returns false for negative points' do
      transaction = build(:loyalty_transaction, points: -100)
      expect(transaction.positive?).to be false
    end

    it 'returns false for zero points' do
      transaction = build(:loyalty_transaction, points: 0)
      expect(transaction.positive?).to be false
    end
  end

  describe '#negative?' do
    it 'returns true for negative points' do
      transaction = build(:loyalty_transaction, points: -100)
      expect(transaction.negative?).to be true
    end

    it 'returns false for positive points' do
      transaction = build(:loyalty_transaction, points: 100)
      expect(transaction.negative?).to be false
    end

    it 'returns false for zero points' do
      transaction = build(:loyalty_transaction, points: 0)
      expect(transaction.negative?).to be false
    end
  end

  describe 'transaction with source' do
    it 'can be associated with a booking' do
      booking = create(:booking)
      transaction = create(:loyalty_transaction, :with_source, source: booking)
      
      expect(transaction.source).to eq(booking)
      expect(transaction.source_type).to eq('Booking')
      expect(transaction.source_id).to eq(booking.id)
    end

    it 'can be associated with a user (for admin adjustments)' do
      user = create(:user)
      transaction = create(:loyalty_transaction, source: user, description: 'Admin adjustment')
      
      expect(transaction.source).to eq(user)
      expect(transaction.source_type).to eq('User')
    end

    it 'can have no source' do
      transaction = create(:loyalty_transaction, source: nil)
      
      expect(transaction.source).to be_nil
      expect(transaction.source_type).to be_nil
      expect(transaction.source_id).to be_nil
    end
  end

  describe 'transaction types and business logic' do
    let(:account) { create(:loyalty_account, points_balance: 500) }

    describe 'earning transactions' do
      it 'records points earned' do
        transaction = create(:loyalty_transaction, 
                           loyalty_account: account,
                           transaction_type: :earn,
                           points: 100,
                           description: 'Booking reward',
                           balance_after: 600)

        expect(transaction.earn?).to be true
        expect(transaction.positive?).to be true
        expect(transaction.points_display).to eq('+100')
      end
    end

    describe 'redemption transactions' do
      it 'records points redeemed' do
        transaction = create(:loyalty_transaction,
                           loyalty_account: account,
                           transaction_type: :redeem,
                           points: -200,
                           description: 'Reward redemption',
                           balance_after: 300)

        expect(transaction.redeem?).to be true
        expect(transaction.negative?).to be true
        expect(transaction.points_display).to eq('-200')
      end
    end

    describe 'adjustment transactions' do
      it 'records manual adjustments' do
        transaction = create(:loyalty_transaction,
                           loyalty_account: account,
                           transaction_type: :adjust,
                           points: 25,
                           description: 'Manual correction',
                           balance_after: 525)

        expect(transaction.adjust?).to be true
        expect(transaction.positive?).to be true
      end
    end

    describe 'expiration transactions' do
      it 'records expired points' do
        transaction = create(:loyalty_transaction,
                           loyalty_account: account,
                           transaction_type: :expire,
                           points: -50,
                           description: 'Points expired',
                           balance_after: 450)

        expect(transaction.expire?).to be true
        expect(transaction.negative?).to be true
        expect(transaction.transaction_icon).to eq('⚠')
      end
    end
  end
end