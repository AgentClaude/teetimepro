import type { Meta, StoryObj } from '@storybook/react';
import { ProductGrid } from '../components/pos/ProductGrid';
import { fn } from '@storybook/test';
import type { PosProduct } from '../types/pos';

const mockProducts: PosProduct[] = [
  {
    id: '1', name: 'Hot Dog', sku: 'FOOD-001', barcode: '111', priceCents: 450,
    category: 'food', description: null, active: true, trackInventory: false,
    stockQuantity: null, inStock: true, formattedPrice: '$4.50',
  },
  {
    id: '2', name: 'Craft Beer', sku: 'BEV-001', barcode: '222', priceCents: 800,
    category: 'beverage', description: null, active: true, trackInventory: true,
    stockQuantity: 24, inStock: true, formattedPrice: '$8.00',
  },
  {
    id: '3', name: 'Golf Polo', sku: 'APP-001', barcode: '333', priceCents: 5500,
    category: 'apparel', description: null, active: true, trackInventory: true,
    stockQuantity: 3, inStock: true, formattedPrice: '$55.00',
  },
  {
    id: '4', name: 'Pro V1 Dozen', sku: 'EQP-001', barcode: '444', priceCents: 5499,
    category: 'equipment', description: null, active: true, trackInventory: true,
    stockQuantity: 0, inStock: false, formattedPrice: '$54.99',
  },
  {
    id: '5', name: 'Cart Rental', sku: 'RNT-001', barcode: null, priceCents: 2500,
    category: 'rental', description: null, active: true, trackInventory: false,
    stockQuantity: null, inStock: true, formattedPrice: '$25.00',
  },
  {
    id: '6', name: 'Cheeseburger', sku: 'FOOD-002', barcode: '555', priceCents: 950,
    category: 'food', description: null, active: true, trackInventory: false,
    stockQuantity: null, inStock: true, formattedPrice: '$9.50',
  },
];

const meta: Meta<typeof ProductGrid> = {
  title: 'POS/ProductGrid',
  component: ProductGrid,
  parameters: { layout: 'padded' },
  args: {
    products: mockProducts,
    onSelect: fn(),
  },
};

export default meta;
type Story = StoryObj<typeof ProductGrid>;

export const Default: Story = {};

export const Loading: Story = {
  args: {
    products: [],
    loading: true,
  },
};

export const Empty: Story = {
  args: {
    products: [],
  },
};

export const FoodOnly: Story = {
  args: {
    products: mockProducts.filter((p) => p.category === 'food'),
  },
};
