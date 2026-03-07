import type { Meta, StoryObj } from '@storybook/react';
import { SyncHistory } from './SyncHistory';
import type { AccountingSync } from '../../types';

const meta: Meta<typeof SyncHistory> = {
  title: 'Accounting/SyncHistory',
  component: SyncHistory,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof SyncHistory>;

const mockSyncHistory: AccountingSync[] = [
  {
    id: '1',
    syncType: 'invoice',
    status: 'completed',
    externalId: 'INV-001',
    retryCount: 0,
    errorMessage: null,
    errorAt: null,
    startedAt: '2024-01-20T14:00:00Z',
    completedAt: '2024-01-20T14:00:05Z',
    createdAt: '2024-01-20T14:00:00Z',
    syncTypeHumanized: 'Invoice',
    provider: 'quickbooks',
    duration: 5,
    retryable: false,
    syncable: {
      id: 'b1',
      confirmationCode: 'TEE-2024-001',
      totalCents: 15000,
      user: { fullName: 'John Smith', email: 'john@example.com' },
    },
  },
  {
    id: '2',
    syncType: 'payment',
    status: 'completed',
    externalId: 'PAY-001',
    retryCount: 0,
    errorMessage: null,
    errorAt: null,
    startedAt: '2024-01-20T13:30:00Z',
    completedAt: '2024-01-20T13:30:03Z',
    createdAt: '2024-01-20T13:30:00Z',
    syncTypeHumanized: 'Payment',
    provider: 'quickbooks',
    duration: 3,
    retryable: false,
    syncable: {
      id: 'p1',
      amountCents: 15000,
      stripePaymentIntentId: 'pi_test_123',
      status: 'succeeded',
      booking: { confirmationCode: 'TEE-2024-001' },
    },
  },
  {
    id: '3',
    syncType: 'invoice',
    status: 'failed',
    externalId: null,
    retryCount: 2,
    errorMessage: 'Authentication token expired',
    errorAt: '2024-01-20T12:00:00Z',
    startedAt: '2024-01-20T12:00:00Z',
    completedAt: null,
    createdAt: '2024-01-20T12:00:00Z',
    syncTypeHumanized: 'Invoice',
    provider: 'quickbooks',
    duration: null,
    retryable: true,
    syncable: {
      id: 'b2',
      confirmationCode: 'TEE-2024-002',
      totalCents: 8500,
      user: { fullName: 'Jane Doe', email: 'jane@example.com' },
    },
  },
  {
    id: '4',
    syncType: 'refund',
    status: 'pending',
    externalId: null,
    retryCount: 0,
    errorMessage: null,
    errorAt: null,
    startedAt: null,
    completedAt: null,
    createdAt: '2024-01-20T15:00:00Z',
    syncTypeHumanized: 'Refund',
    provider: 'quickbooks',
    duration: null,
    retryable: false,
    syncable: {
      id: 'p2',
      amountCents: 5000,
      status: 'refunded',
      booking: { confirmationCode: 'TEE-2024-003' },
    },
  },
  {
    id: '5',
    syncType: 'invoice',
    status: 'in_progress',
    externalId: null,
    retryCount: 0,
    errorMessage: null,
    errorAt: null,
    startedAt: '2024-01-20T15:05:00Z',
    completedAt: null,
    createdAt: '2024-01-20T15:05:00Z',
    syncTypeHumanized: 'Invoice',
    provider: 'xero',
    duration: null,
    retryable: false,
    syncable: {
      id: 'b3',
      confirmationCode: 'TEE-2024-004',
      totalCents: 22000,
      user: { fullName: 'Bob Wilson', email: 'bob@example.com' },
    },
  },
];

export const Default: Story = {
  args: {
    syncHistory: mockSyncHistory,
    onRetrySync: (sync: AccountingSync) => console.log('Retry sync:', sync.id),
  },
};

export const Empty: Story = {
  args: {
    syncHistory: [],
    onRetrySync: (sync: AccountingSync) => console.log('Retry sync:', sync.id),
  },
};

export const AllCompleted: Story = {
  args: {
    syncHistory: mockSyncHistory
      .filter((s) => s.status === 'completed')
      .concat([
        {
          ...mockSyncHistory[0],
          id: '6',
          syncType: 'refund',
          syncTypeHumanized: 'Refund',
          completedAt: '2024-01-19T10:00:00Z',
          createdAt: '2024-01-19T10:00:00Z',
        },
      ]),
    onRetrySync: (sync: AccountingSync) => console.log('Retry sync:', sync.id),
  },
};

export const AllFailed: Story = {
  args: {
    syncHistory: [
      mockSyncHistory[2],
      {
        ...mockSyncHistory[2],
        id: '7',
        errorMessage: 'Rate limit exceeded',
        retryCount: 3,
        retryable: false,
      },
      {
        ...mockSyncHistory[2],
        id: '8',
        syncType: 'payment',
        syncTypeHumanized: 'Payment',
        errorMessage: 'Invalid account mapping',
        retryCount: 1,
        retryable: true,
      },
    ],
    onRetrySync: (sync: AccountingSync) => console.log('Retry sync:', sync.id),
  },
};

export const WithoutRetryHandler: Story = {
  args: {
    syncHistory: mockSyncHistory,
  },
};
