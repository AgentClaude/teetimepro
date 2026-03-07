import type { Meta, StoryObj } from '@storybook/react';
import { AccountMappingConfig } from './AccountMappingConfig';
import type { AccountingIntegration } from '../../types';

const meta: Meta<typeof AccountMappingConfig> = {
  title: 'Accounting/AccountMappingConfig',
  component: AccountMappingConfig,
  tags: ['autodocs'],
  argTypes: {
    provider: {
      control: 'select',
      options: ['quickbooks', 'xero'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof AccountMappingConfig>;

const fullyMappedIntegration: AccountingIntegration = {
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

const partiallyMappedIntegration: AccountingIntegration = {
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

const emptyMappingIntegration: AccountingIntegration = {
  id: '2',
  provider: 'xero',
  status: 'connected',
  companyName: 'Oakmont Country Club',
  countryCode: 'US',
  connectedAt: '2024-01-10T09:00:00Z',
  lastSyncAt: null,
  accountMapping: {},
  settings: {},
  lastErrorMessage: null,
  lastErrorAt: null,
  connected: true,
  companyId: 'XERO_abc123',
};

export const FullyMapped: Story = {
  args: {
    provider: 'quickbooks',
    integration: fullyMappedIntegration,
    onConfigureMapping: (category: string, accountId: string, accountName: string) =>
      console.log('Configure mapping:', category, accountId, accountName),
  },
};

export const PartiallyMapped: Story = {
  args: {
    provider: 'quickbooks',
    integration: partiallyMappedIntegration,
    onConfigureMapping: (category: string, accountId: string, accountName: string) =>
      console.log('Configure mapping:', category, accountId, accountName),
  },
};

export const EmptyMapping: Story = {
  args: {
    provider: 'xero',
    integration: emptyMappingIntegration,
    onConfigureMapping: (category: string, accountId: string, accountName: string) =>
      console.log('Configure mapping:', category, accountId, accountName),
  },
};

export const XeroFullyMapped: Story = {
  args: {
    provider: 'xero',
    integration: {
      ...fullyMappedIntegration,
      id: '2',
      provider: 'xero',
      companyName: 'Oakmont Country Club',
      companyId: 'XERO_abc123',
    },
    onConfigureMapping: (category: string, accountId: string, accountName: string) =>
      console.log('Configure mapping:', category, accountId, accountName),
  },
};
