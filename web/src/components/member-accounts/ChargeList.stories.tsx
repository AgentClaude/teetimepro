import type { Meta, StoryObj } from '@storybook/react';
import { ChargeList } from './ChargeList';
import type { MemberAccountCharge } from './types';

const meta: Meta<typeof ChargeList> = {
  title: 'Member Accounts/ChargeList',
  component: ChargeList,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof ChargeList>;

const sampleCharges: MemberAccountCharge[] = [
  {
    id: '1',
    chargeType: 'fnb',
    status: 'posted',
    amountCents: 45_50,
    amountCurrency: 'USD',
    description: 'F&B Tab - John Smith (3 items)',
    createdAt: '2026-03-06T14:30:00Z',
    memberName: 'John Smith',
    voidable: true,
    chargedBy: { fullName: 'Sarah Johnson' },
    membership: { id: '1', user: { fullName: 'John Smith' } },
    fnbTab: { id: '1', golferName: 'John Smith' },
  },
  {
    id: '2',
    chargeType: 'pro_shop',
    status: 'posted',
    amountCents: 89_99,
    amountCurrency: 'USD',
    description: 'Pro shop - Titleist Pro V1 (dozen)',
    createdAt: '2026-03-05T10:15:00Z',
    memberName: 'John Smith',
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
    description: 'Tee time - Sat 9:30 AM',
    createdAt: '2026-03-04T08:00:00Z',
    memberName: 'John Smith',
    voidable: true,
    chargedBy: { fullName: 'Front Desk' },
    membership: { id: '1', user: { fullName: 'John Smith' } },
  },
  {
    id: '4',
    chargeType: 'fnb',
    status: 'voided',
    amountCents: 22_00,
    amountCurrency: 'USD',
    description: 'F&B Tab - Wrong customer',
    voidedAt: '2026-03-04T15:00:00Z',
    createdAt: '2026-03-04T14:00:00Z',
    memberName: 'John Smith',
    voidable: false,
    chargedBy: { fullName: 'Sarah Johnson' },
    membership: { id: '1', user: { fullName: 'John Smith' } },
  },
];

export const Default: Story = {
  args: {
    charges: sampleCharges,
    onVoidCharge: (id: string) => alert(`Void charge ${id}`),
  },
};

export const WithMemberNames: Story = {
  args: {
    charges: sampleCharges,
    showMemberName: true,
    onVoidCharge: (id: string) => alert(`Void charge ${id}`),
  },
};

export const Empty: Story = {
  args: {
    charges: [],
  },
};

export const Loading: Story = {
  args: {
    charges: [],
    loading: true,
  },
};
