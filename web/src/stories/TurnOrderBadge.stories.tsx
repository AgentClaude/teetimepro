import type { Meta, StoryObj } from '@storybook/react';
import { TurnOrderBadge } from '../components/turn-order/TurnOrderBadge';

const meta: Meta<typeof TurnOrderBadge> = {
  title: 'TurnOrder/TurnOrderBadge',
  component: TurnOrderBadge,
  parameters: { layout: 'padded' },
};

export default meta;
type Story = StoryObj<typeof TurnOrderBadge>;

export const Open: Story = {
  args: {
    deliveryHole: 10,
    totalCents: 1700,
    status: 'open',
  },
};

export const Closed: Story = {
  args: {
    deliveryHole: 14,
    totalCents: 2350,
    status: 'closed',
  },
};

export const NoHole: Story = {
  args: {
    deliveryHole: null,
    totalCents: 900,
    status: 'open',
  },
};
