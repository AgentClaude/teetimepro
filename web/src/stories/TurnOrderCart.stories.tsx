import type { Meta, StoryObj } from '@storybook/react';
import { TurnOrderCart } from '../components/turn-order/TurnOrderCart';
import { fn } from '@storybook/test';
import type { TurnOrderCartItem } from '../types/turnOrder';

const mockItems: TurnOrderCartItem[] = [
  {
    product: {
      id: '1', name: 'Hot Dog', sku: 'FOOD-001', barcode: '111', priceCents: 450,
      category: 'food', description: null, active: true, trackInventory: false,
      stockQuantity: null, inStock: true, formattedPrice: '$4.50',
    },
    quantity: 2,
  },
  {
    product: {
      id: '2', name: 'Craft Beer', sku: 'BEV-001', barcode: '222', priceCents: 800,
      category: 'beverage', description: null, active: true, trackInventory: true,
      stockQuantity: 24, inStock: true, formattedPrice: '$8.00',
    },
    quantity: 1,
  },
];

const meta: Meta<typeof TurnOrderCart> = {
  title: 'TurnOrder/TurnOrderCart',
  component: TurnOrderCart,
  parameters: { layout: 'padded' },
  args: {
    items: mockItems,
    deliveryHole: 10,
    deliveryNotes: '',
    onUpdateQuantity: fn(),
    onRemoveItem: fn(),
    onDeliveryHoleChange: fn(),
    onDeliveryNotesChange: fn(),
    onSubmit: fn(),
  },
  decorators: [
    (Story) => (
      <div style={{ width: 288 }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof TurnOrderCart>;

export const WithItems: Story = {};

export const Empty: Story = {
  args: { items: [] },
};

export const WithNotes: Story = {
  args: {
    deliveryNotes: 'Extra ketchup, no onions',
    deliveryHole: 14,
  },
};

export const Loading: Story = {
  args: { loading: true },
};
