import type { Meta, StoryObj } from '@storybook/react';
import { PrepaidPurchaseList } from './PrepaidPurchaseList';

const meta: Meta<typeof PrepaidPurchaseList> = {
  title: 'Prepaid/PrepaidPurchaseList',
  component: PrepaidPurchaseList,
  parameters: { layout: 'padded' },
};

export default meta;
type Story = StoryObj<typeof PrepaidPurchaseList>;

const mockPurchases = [
  {
    id: '1',
    code: 'PP-ABC12345',
    status: 'active',
    roundsRemaining: 7,
    balance: null,
    purchasedAt: '2026-01-15T10:00:00Z',
    expiresAt: '2027-01-15T10:00:00Z',
    usable: true,
    totalRoundsUsed: 3,
    prepaidPackage: {
      name: 'Weekend 10-Pack',
      packageType: 'ROUND_PACK' as const,
    },
  },
  {
    id: '2',
    code: 'PP-DEF67890',
    status: 'active',
    roundsRemaining: null,
    balance: { amountCents: 17500, currency: 'USD' },
    purchasedAt: '2026-02-20T14:00:00Z',
    expiresAt: null,
    usable: true,
    totalRoundsUsed: 0,
    prepaidPackage: {
      name: 'Gift Card $250',
      packageType: 'VALUE_CARD' as const,
    },
  },
  {
    id: '3',
    code: 'PP-GHI11111',
    status: 'active',
    roundsRemaining: null,
    balance: null,
    purchasedAt: '2026-03-01T09:00:00Z',
    expiresAt: '2026-03-31T09:00:00Z',
    usable: true,
    totalRoundsUsed: 12,
    prepaidPackage: {
      name: 'Monthly Unlimited',
      packageType: 'TIME_PASS' as const,
    },
  },
  {
    id: '4',
    code: 'PP-JKL22222',
    status: 'fully_redeemed',
    roundsRemaining: 0,
    balance: null,
    purchasedAt: '2025-11-01T10:00:00Z',
    expiresAt: '2026-11-01T10:00:00Z',
    usable: false,
    totalRoundsUsed: 10,
    prepaidPackage: {
      name: 'Weekday 10-Pack',
      packageType: 'ROUND_PACK' as const,
    },
  },
];

export const Default: Story = {
  args: {
    purchases: mockPurchases,
    onRedeem: (id: string) => console.log('Redeem', id),
  },
};

export const Empty: Story = {
  args: {
    purchases: [],
  },
};

export const ActiveOnly: Story = {
  args: {
    purchases: mockPurchases.filter((p) => p.status === 'active'),
    onRedeem: (id: string) => console.log('Redeem', id),
  },
};

export const ReadOnly: Story = {
  args: {
    purchases: mockPurchases,
  },
};
