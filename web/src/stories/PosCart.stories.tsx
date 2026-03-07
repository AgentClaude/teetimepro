import type { Meta, StoryObj } from '@storybook/react';
import { PosCart } from '../components/pos/PosCart';
import { fn } from '@storybook/test';
import type { CartItem } from '../types/pos';

const mockItems: CartItem[] = [
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

const meta: Meta<typeof PosCart> = {
  title: 'POS/PosCart',
  component: PosCart,
  parameters: { layout: 'padded' },
  args: {
    items: mockItems,
    golferName: 'John Smith',
    onUpdateQuantity: fn(),
    onRemoveItem: fn(),
    onClear: fn(),
    onCheckout: fn(),
    onGolferNameChange: fn(),
  },
  decorators: [
    (Story) => (
      <div style={{ width: 384, height: 600 }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof PosCart>;

export const WithItems: Story = {};

export const Empty: Story = {
  args: {
    items: [],
    golferName: '',
  },
};

export const Loading: Story = {
  args: {
    loading: true,
  },
};

export const NoName: Story = {
  args: {
    golferName: '',
  },
};
