import type { Meta, StoryObj } from '@storybook/react';
import { MemberAccountSummary } from './MemberAccountSummary';
import type { MembershipAccount } from './types';

const meta: Meta<typeof MemberAccountSummary> = {
  title: 'Member Accounts/MemberAccountSummary',
  component: MemberAccountSummary,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof MemberAccountSummary>;

const baseMembership: MembershipAccount = {
  id: '1',
  tier: 'gold',
  status: 'active',
  accountBalanceCents: 150_00,
  creditLimitCents: 500_000,
  availableCreditCents: 498_500,
  startsAt: '2025-01-01T00:00:00Z',
  endsAt: '2026-01-01T00:00:00Z',
  user: {
    id: '1',
    fullName: 'John Smith',
    email: 'john@example.com',
  },
  recentCharges: [],
};

export const Default: Story = {
  args: {
    membership: baseMembership,
    onViewStatement: () => alert('View statement'),
    onChargeAccount: () => alert('New charge'),
  },
};

export const HighBalance: Story = {
  args: {
    membership: {
      ...baseMembership,
      accountBalanceCents: 450_000,
      availableCreditCents: 50_000,
    },
    onViewStatement: () => alert('View statement'),
    onChargeAccount: () => alert('New charge'),
  },
};

export const NearLimit: Story = {
  args: {
    membership: {
      ...baseMembership,
      accountBalanceCents: 490_000,
      availableCreditCents: 10_000,
    },
    onViewStatement: () => alert('View statement'),
    onChargeAccount: () => alert('New charge'),
  },
};

export const PlatinumTier: Story = {
  args: {
    membership: {
      ...baseMembership,
      tier: 'platinum',
      creditLimitCents: 1_000_000,
      availableCreditCents: 850_000,
      accountBalanceCents: 150_000,
    },
    onViewStatement: () => alert('View statement'),
    onChargeAccount: () => alert('New charge'),
  },
};

export const ZeroBalance: Story = {
  args: {
    membership: {
      ...baseMembership,
      accountBalanceCents: 0,
      availableCreditCents: 500_000,
    },
    onViewStatement: () => alert('View statement'),
    onChargeAccount: () => alert('New charge'),
  },
};
