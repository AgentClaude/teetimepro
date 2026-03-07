import type { Meta, StoryObj } from '@storybook/react';
import { CustomerLoyaltySection } from './CustomerLoyaltySection';

const meta: Meta<typeof CustomerLoyaltySection> = {
  title: 'Customers/CustomerLoyaltySection',
  component: CustomerLoyaltySection,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof CustomerLoyaltySection>;

const sampleLoyaltyAccount = {
  id: 'la1',
  pointsBalance: 2450,
  lifetimePoints: 8750,
  tier: 'gold',
  tierName: 'Gold',
  pointsNeededForNextTier: 1250,
  recentTransactions: [
    {
      id: 'lt1',
      transactionType: 'earn',
      points: 150,
      description: 'Round at Pinehurst No. 2',
      balanceAfter: 2450,
      createdAt: '2026-03-06T14:00:00Z',
    },
    {
      id: 'lt2',
      transactionType: 'redeem',
      points: -500,
      description: 'Free range bucket',
      balanceAfter: 2300,
      createdAt: '2026-03-03T10:00:00Z',
    },
    {
      id: 'lt3',
      transactionType: 'earn',
      points: 200,
      description: 'Weekend round bonus',
      balanceAfter: 2800,
      createdAt: '2026-02-28T16:00:00Z',
    },
    {
      id: 'lt4',
      transactionType: 'adjust',
      points: 100,
      description: 'Birthday bonus',
      balanceAfter: 2600,
      createdAt: '2026-02-15T08:00:00Z',
    },
    {
      id: 'lt5',
      transactionType: 'earn',
      points: 150,
      description: 'Round at Augusta National',
      balanceAfter: 2500,
      createdAt: '2026-02-10T12:00:00Z',
    },
  ],
};

export const WithPoints: Story = {
  args: {
    loyaltyAccount: sampleLoyaltyAccount,
  },
};

export const MaxTier: Story = {
  args: {
    loyaltyAccount: {
      ...sampleLoyaltyAccount,
      tier: 'platinum',
      tierName: 'Platinum',
      pointsNeededForNextTier: 0,
      lifetimePoints: 25000,
      pointsBalance: 5200,
    },
  },
};

export const Compact: Story = {
  args: {
    loyaltyAccount: sampleLoyaltyAccount,
    compact: true,
  },
};

export const NotEnrolled: Story = {
  args: {
    loyaltyAccount: null,
  },
};

export const BronzeTier: Story = {
  args: {
    loyaltyAccount: {
      ...sampleLoyaltyAccount,
      tier: 'bronze',
      tierName: 'Bronze',
      pointsBalance: 120,
      lifetimePoints: 120,
      pointsNeededForNextTier: 880,
      recentTransactions: [sampleLoyaltyAccount.recentTransactions[0]],
    },
  },
};
