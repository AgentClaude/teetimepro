import type { Meta, StoryObj } from '@storybook/react';
import { MemberStatement } from './MemberStatement';
import type { MemberAccountStatement } from './types';

const meta: Meta<typeof MemberStatement> = {
  title: 'Member Accounts/MemberStatement',
  component: MemberStatement,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof MemberStatement>;

const sampleStatement: MemberAccountStatement = {
  membership: {
    id: '1',
    tier: 'gold',
    status: 'active',
    accountBalanceCents: 210_49,
    creditLimitCents: 500_000,
    availableCreditCents: 497_951,
    startsAt: '2025-01-01T00:00:00Z',
    endsAt: '2026-01-01T00:00:00Z',
    user: {
      id: '1',
      fullName: 'John Smith',
      email: 'john@example.com',
    },
    recentCharges: [],
  },
  charges: [
    {
      id: '1',
      chargeType: 'fnb',
      status: 'posted',
      amountCents: 45_50,
      amountCurrency: 'USD',
      description: 'F&B Tab - Lunch (3 items)',
      createdAt: '2026-03-06T14:30:00Z',
      voidable: true,
      chargedBy: { fullName: 'Sarah Johnson' },
      membership: { id: '1', user: { fullName: 'John Smith' } },
    },
    {
      id: '2',
      chargeType: 'pro_shop',
      status: 'posted',
      amountCents: 89_99,
      amountCurrency: 'USD',
      description: 'Pro shop - Titleist Pro V1',
      createdAt: '2026-03-05T10:15:00Z',
      voidable: true,
      chargedBy: { fullName: 'Mike Davis' },
      membership: { id: '1', user: { fullName: 'John Smith' } },
    },
    {
      id: '3',
      chargeType: 'booking',
      status: 'posted',
      amountCents: 75_00,
      amountCurrency: 'USD',
      description: 'Tee time booking - Sat 9:30 AM',
      createdAt: '2026-03-04T08:00:00Z',
      voidable: true,
      chargedBy: { fullName: 'Front Desk' },
      membership: { id: '1', user: { fullName: 'John Smith' } },
    },
  ],
  totalCount: 3,
  currentBalanceCents: 210_49,
  creditLimitCents: 500_000,
  availableCreditCents: 497_951,
  periodTotalCents: 210_49,
  page: 1,
  perPage: 25,
  totalPages: 1,
};

export const Default: Story = {
  args: {
    statement: sampleStatement,
    onBack: () => alert('Back'),
    onVoidCharge: (id: string) => alert(`Void ${id}`),
  },
};

export const MultiPage: Story = {
  args: {
    statement: {
      ...sampleStatement,
      totalCount: 75,
      totalPages: 3,
      page: 2,
    },
    onPageChange: (page: number) => alert(`Page ${page}`),
    onBack: () => alert('Back'),
    onVoidCharge: (id: string) => alert(`Void ${id}`),
  },
};

export const Empty: Story = {
  args: {
    statement: {
      ...sampleStatement,
      charges: [],
      totalCount: 0,
      periodTotalCents: 0,
    },
    onBack: () => alert('Back'),
  },
};
