import type { Meta, StoryObj } from '@storybook/react';
import { AccountingSettings } from './AccountingSettings';
import type { AccountingIntegration, AccountingSync } from '../../types';

const meta: Meta<typeof AccountingSettings> = {
  title: 'Accounting/AccountingSettings',
  component: AccountingSettings,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof AccountingSettings>;

const mockQuickBooksIntegration: AccountingIntegration = {
  id: '1',
  provider: 'quickbooks',
  status: 'connected',
  companyName: 'Pine Valley Golf Club',
  countryCode: 'US',
  connectedAt: '2024-01-15T10:30:00Z',
  lastSyncAt: '2024-01-20T14:15:00Z',
  accountMapping: {
    green_fees: { account_id: '1', account_name: 'Green Fees Revenue' },
    cart_fees: { account_id: '2', account_name: 'Cart Rental Income' },
    merchandise: { account_id: '3', account_name: 'Pro Shop Sales' },
    food_beverage: { account_id: '4', account_name: 'F&B Revenue' },
    lessons: { account_id: '5', account_name: 'Instruction Fees' },
    tournaments: { account_id: '6', account_name: 'Tournament Revenue' },
    bank_deposits: { account_id: '35', account_name: 'Checking Account' },
  },
  settings: {},
  lastErrorMessage: null,
  lastErrorAt: null,
  connected: true,
  companyId: 'QB_123456789',
};

const mockXeroIntegration: AccountingIntegration = {
  id: '2',
  provider: 'xero',
  status: 'connected',
  companyName: 'Oakmont Country Club',
  countryCode: 'US',
  connectedAt: '2024-01-10T09:00:00Z',
  lastSyncAt: '2024-01-19T16:45:00Z',
  accountMapping: {
    green_fees: { account_id: '200', account_name: 'Sales Revenue' },
    bank_deposits: { account_id: '090', account_name: 'Business Bank Account' },
  },
  settings: {},
  lastErrorMessage: null,
  lastErrorAt: null,
  connected: true,
  companyId: 'XERO_abc123',
};

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
    status: 'failed',
    externalId: null,
    retryCount: 1,
    errorMessage: 'Token expired',
    errorAt: '2024-01-20T13:00:00Z',
    startedAt: '2024-01-20T13:00:00Z',
    completedAt: null,
    createdAt: '2024-01-20T13:00:00Z',
    syncTypeHumanized: 'Payment',
    provider: 'quickbooks',
    duration: null,
    retryable: true,
    syncable: {
      id: 'p1',
      amountCents: 15000,
      stripePaymentIntentId: 'pi_test_456',
      status: 'succeeded',
      booking: { confirmationCode: 'TEE-2024-001' },
    },
  },
];

const defaultHandlers = {
  onConnect: (provider: 'quickbooks' | 'xero') => console.log('Connect:', provider),
  onDisconnect: (provider: 'quickbooks' | 'xero') => console.log('Disconnect:', provider),
  onSync: (provider: 'quickbooks' | 'xero', syncType?: string, force?: boolean) =>
    console.log('Sync:', provider, syncType, force),
  onConfigureMapping: (provider: 'quickbooks' | 'xero', category: string, accountId: string, accountName: string) =>
    console.log('Configure mapping:', provider, category, accountId, accountName),
};

export const Default: Story = {
  args: {
    quickbooksIntegration: mockQuickBooksIntegration,
    xeroIntegration: mockXeroIntegration,
    syncHistory: mockSyncHistory,
    loading: false,
    ...defaultHandlers,
  },
};

export const NoIntegrations: Story = {
  args: {
    syncHistory: [],
    loading: false,
    ...defaultHandlers,
  },
};

export const QuickBooksOnly: Story = {
  args: {
    quickbooksIntegration: mockQuickBooksIntegration,
    syncHistory: mockSyncHistory,
    loading: false,
    ...defaultHandlers,
  },
};

export const XeroOnly: Story = {
  args: {
    xeroIntegration: mockXeroIntegration,
    syncHistory: [],
    loading: false,
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    syncHistory: [],
    loading: true,
    ...defaultHandlers,
  },
};

export const FullyMappedQuickBooks: Story = {
  args: {
    quickbooksIntegration: mockQuickBooksIntegration,
    syncHistory: mockSyncHistory,
    loading: false,
    ...defaultHandlers,
  },
};

export const ErrorState: Story = {
  args: {
    quickbooksIntegration: {
      ...mockQuickBooksIntegration,
      status: 'error',
      lastErrorMessage: 'Authentication token expired. Please reconnect.',
      lastErrorAt: '2024-01-20T12:00:00Z',
      connected: false,
    },
    syncHistory: mockSyncHistory,
    loading: false,
    ...defaultHandlers,
  },
};
