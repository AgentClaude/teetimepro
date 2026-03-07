import type { Meta, StoryObj } from '@storybook/react';
import { ProductListWithInventory } from './ProductListWithInventory';
import type { PosProduct } from '../../types/pos';

const meta: Meta<typeof ProductListWithInventory> = {
  title: 'POS/ProductListWithInventory',
  component: ProductListWithInventory,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof ProductListWithInventory>;

const mockProducts: PosProduct[] = [
  {
    id: '1',
    name: 'Golf Balls (Dozen)',
    sku: 'GB001',
    barcode: '123456789',
    priceCents: 1500,
    category: 'equipment',
    description: 'Premium golf balls',
    active: true,
    trackInventory: true,
    stockQuantity: 45,
    inStock: true,
    formattedPrice: '$15.00',
    needsReorder: false,
    inventoryLevels: [
      {
        id: '1',
        posProduct: {} as PosProduct,
        course: { id: '1', name: 'Main Course' },
        currentStock: 25,
        reservedStock: 0,
        availableStock: 25,
        reorderPoint: 10,
        reorderQuantity: 50,
        needsReorder: false,
        stockStatus: 'in_stock',
        averageCostCents: 1200,
        lastCostCents: 1250,
        stockValueCents: 30000,
        lastCountedAt: '2024-01-20T10:00:00Z',
        lastCountedBy: { id: '1', firstName: 'John', lastName: 'Doe' },
      },
      {
        id: '2',
        posProduct: {} as PosProduct,
        course: { id: '2', name: 'Pro Shop' },
        currentStock: 20,
        reservedStock: 5,
        availableStock: 15,
        reorderPoint: 15,
        reorderQuantity: 30,
        needsReorder: false,
        stockStatus: 'in_stock',
        averageCostCents: 1200,
        lastCostCents: 1250,
        stockValueCents: 24000,
        lastCountedAt: '2024-01-18T14:30:00Z',
        lastCountedBy: { id: '2', firstName: 'Jane', lastName: 'Smith' },
      },
    ],
    inventoryMovements: [],
  },
  {
    id: '2',
    name: 'Golf Tees (Pack)',
    sku: 'GT001',
    barcode: '123456790',
    priceCents: 500,
    category: 'equipment',
    description: 'Wooden golf tees',
    active: true,
    trackInventory: true,
    stockQuantity: 8,
    inStock: true,
    formattedPrice: '$5.00',
    needsReorder: true,
    inventoryLevels: [
      {
        id: '3',
        posProduct: {} as PosProduct,
        course: { id: '1', name: 'Main Course' },
        currentStock: 8,
        reservedStock: 0,
        availableStock: 8,
        reorderPoint: 20,
        reorderQuantity: 100,
        needsReorder: true,
        stockStatus: 'low_stock',
        averageCostCents: 300,
        lastCostCents: 320,
        stockValueCents: 2400,
        lastCountedAt: '2024-01-19T09:15:00Z',
        lastCountedBy: { id: '1', firstName: 'John', lastName: 'Doe' },
      },
    ],
    inventoryMovements: [],
  },
  {
    id: '3',
    name: 'Energy Drink',
    sku: 'ED001',
    barcode: null,
    priceCents: 250,
    category: 'beverage',
    description: 'Sports energy drink',
    active: true,
    trackInventory: true,
    stockQuantity: 0,
    inStock: false,
    formattedPrice: '$2.50',
    needsReorder: true,
    inventoryLevels: [
      {
        id: '4',
        posProduct: {} as PosProduct,
        course: { id: '2', name: 'Pro Shop' },
        currentStock: 0,
        reservedStock: 0,
        availableStock: 0,
        reorderPoint: 24,
        reorderQuantity: 48,
        needsReorder: true,
        stockStatus: 'out_of_stock',
        averageCostCents: 150,
        lastCostCents: 150,
        stockValueCents: 0,
        lastCountedAt: '2024-01-21T16:45:00Z',
        lastCountedBy: { id: '2', firstName: 'Jane', lastName: 'Smith' },
      },
    ],
    inventoryMovements: [],
  },
  {
    id: '4',
    name: 'Golf Shirt',
    sku: 'GS001',
    barcode: '123456791',
    priceCents: 4500,
    category: 'apparel',
    description: 'Premium golf polo shirt',
    active: false,
    trackInventory: false,
    stockQuantity: null,
    inStock: true,
    formattedPrice: '$45.00',
    needsReorder: false,
    inventoryLevels: [],
    inventoryMovements: [],
  },
];

export const Default: Story = {
  args: {
    products: mockProducts,
    showInventoryDetails: true,
    loading: false,
  },
};

export const Loading: Story = {
  args: {
    products: [],
    loading: true,
  },
};

export const WithoutInventoryDetails: Story = {
  args: {
    products: mockProducts,
    showInventoryDetails: false,
    loading: false,
  },
};

export const EmptyState: Story = {
  args: {
    products: [],
    loading: false,
  },
};