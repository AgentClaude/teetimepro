import type { Meta, StoryObj } from '@storybook/react';
import { PrepaidPackageCard } from './PrepaidPackageCard';

const meta: Meta<typeof PrepaidPackageCard> = {
  title: 'Prepaid/PrepaidPackageCard',
  component: PrepaidPackageCard,
  parameters: { layout: 'centered' },
  decorators: [
    (Story) => (
      <div style={{ width: 400 }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof PrepaidPackageCard>;

export const RoundPack: Story = {
  args: {
    package: {
      id: '1',
      name: 'Weekend 10-Pack',
      description:
        'Save big with 10 rounds of golf. Perfect for regular weekend players.',
      packageType: 'ROUND_PACK',
      roundsIncluded: 10,
      price: { amountCents: 50000, currency: 'USD' },
      value: null,
      validityDays: 365,
      maxPlayersPerRound: 4,
      transferable: false,
      available: true,
    },
    onPurchase: (id: string) => console.log('Purchase', id),
  },
};

export const ValueCard: Story = {
  args: {
    package: {
      id: '2',
      name: 'Pro Shop Gift Card',
      description: '$250 gift card redeemable for green fees and pro shop purchases.',
      packageType: 'VALUE_CARD',
      roundsIncluded: null,
      price: { amountCents: 25000, currency: 'USD' },
      value: { amountCents: 25000, currency: 'USD' },
      validityDays: null,
      maxPlayersPerRound: 4,
      transferable: true,
      available: true,
    },
    onPurchase: (id: string) => console.log('Purchase', id),
  },
};

export const TimePass: Story = {
  args: {
    package: {
      id: '3',
      name: 'Monthly Unlimited',
      description:
        'Play as much as you want for 30 days. Weekday tee times only.',
      packageType: 'TIME_PASS',
      roundsIncluded: null,
      price: { amountCents: 29900, currency: 'USD' },
      value: null,
      validityDays: 30,
      maxPlayersPerRound: 2,
      transferable: false,
      available: true,
    },
    onPurchase: (id: string) => console.log('Purchase', id),
  },
};

export const Unavailable: Story = {
  args: {
    package: {
      id: '4',
      name: 'Summer Special',
      description: 'Limited time summer package - no longer available.',
      packageType: 'ROUND_PACK',
      roundsIncluded: 20,
      price: { amountCents: 80000, currency: 'USD' },
      value: null,
      validityDays: 120,
      maxPlayersPerRound: 4,
      transferable: false,
      available: false,
    },
    onPurchase: (id: string) => console.log('Purchase', id),
  },
};

export const Compact: Story = {
  args: {
    package: {
      id: '1',
      name: 'Weekend 10-Pack',
      description: 'This description should be hidden in compact mode.',
      packageType: 'ROUND_PACK',
      roundsIncluded: 10,
      price: { amountCents: 50000, currency: 'USD' },
      value: null,
      validityDays: 365,
      maxPlayersPerRound: 4,
      transferable: false,
      available: true,
    },
    compact: true,
  },
};
