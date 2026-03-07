import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { CustomerProfileSection } from './CustomerProfileSection';

const meta: Meta<typeof CustomerProfileSection> = {
  title: 'Customers/CustomerProfileSection',
  component: CustomerProfileSection,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof CustomerProfileSection>;

const baseCustomer = {
  id: '1',
  firstName: 'John',
  lastName: 'Smith',
  fullName: 'John Smith',
  email: 'john.smith@example.com',
  phone: '(555) 123-4567',
  role: 'golfer',
  bookingsCount: 42,
  createdAt: '2025-06-15T00:00:00Z',
};

export const WithMembership: Story = {
  args: {
    customer: {
      ...baseCustomer,
      golferProfile: {
        handicapIndex: 12.4,
        homeCourse: 'Pinehurst No. 2',
        preferredTee: 'blue',
      },
      membership: {
        id: 'm1',
        tier: 'gold',
        status: 'active',
        startsAt: '2026-01-01T00:00:00Z',
        endsAt: '2026-12-31T00:00:00Z',
        daysRemaining: 299,
        accountBalanceCents: 15000,
        creditLimitCents: 50000,
        availableCreditCents: 35000,
      },
    },
  },
};

export const NoMembership: Story = {
  args: {
    customer: {
      ...baseCustomer,
      golferProfile: null,
      membership: null,
    },
  },
};

export const ExpiredMembership: Story = {
  args: {
    customer: {
      ...baseCustomer,
      golferProfile: {
        handicapIndex: null,
        homeCourse: null,
        preferredTee: null,
      },
      membership: {
        id: 'm2',
        tier: 'silver',
        status: 'expired',
        startsAt: '2025-01-01T00:00:00Z',
        endsAt: '2025-12-31T00:00:00Z',
        daysRemaining: 0,
        accountBalanceCents: 0,
        creditLimitCents: 25000,
        availableCreditCents: 25000,
      },
    },
  },
};
