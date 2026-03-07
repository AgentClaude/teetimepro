import type { Meta, StoryObj } from '@storybook/react';
import { ConnectionStatus } from './ConnectionStatus';
import type { AccountingIntegration } from '../../types';

const meta: Meta<typeof ConnectionStatus> = {
  title: 'Accounting/ConnectionStatus',
  component: ConnectionStatus,
  tags: ['autodocs'],
  argTypes: {
    provider: {
      control: 'select',
      options: ['quickbooks', 'xero'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof ConnectionStatus>;

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

const errorIntegration: AccountingIntegration = {
  ...mockQuickBooksIntegration,
  status: 'error',
  lastErrorMessage: 'Authentication token expired. Please reconnect.',
  lastErrorAt: '2024-01-20T12:00:00Z',
  connected: false,
};

export const QuickBooksConnected: Story = {
  args: {
    provider: 'quickbooks',
    integration: mockQuickBooksIntegration,
    onConnect: () => console.log('Connect QuickBooks'),
    onDisconnect: () => console.log('Disconnect QuickBooks'),
    onSync: (syncType, force) => console.log('Sync', syncType, force),
  },
};

export const XeroConnected: Story = {
  args: {
    provider: 'xero',
    integration: mockXeroIntegration,
    onConnect: () => console.log('Connect Xero'),
    onDisconnect: () => console.log('Disconnect Xero'),
    onSync: (syncType, force) => console.log('Sync', syncType, force),
  },
};

export const NotConnected: Story = {
  args: {
    provider: 'quickbooks',
    onConnect: () => console.log('Connect QuickBooks'),
    onDisconnect: () => console.log('Disconnect QuickBooks'),
    onSync: (syncType, force) => console.log('Sync', syncType, force),
  },
};

export const ErrorState: Story = {
  args: {
    provider: 'quickbooks',
    integration: errorIntegration,
    onConnect: () => console.log('Connect QuickBooks'),
    onDisconnect: () => console.log('Disconnect QuickBooks'),
    onSync: (syncType, force) => console.log('Sync', syncType, force),
  },
};

export const Disconnected: Story = {
  args: {
    provider: 'xero',
    integration: {
      ...mockXeroIntegration,
      status: 'disconnected',
      connected: false,
      connectedAt: null,
      lastSyncAt: null,
    },
    onConnect: () => console.log('Connect Xero'),
    onDisconnect: () => console.log('Disconnect Xero'),
    onSync: (syncType, force) => console.log('Sync', syncType, force),
  },
};
