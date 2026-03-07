import type { Meta, StoryObj } from '@storybook/react';
import { LowStockAlert } from './LowStockAlert';
import type { InventoryLevel, PosProduct } from '../../types/pos';

const meta: Meta<typeof LowStockAlert> = {
  title: 'POS/LowStockAlert',
  component: LowStockAlert,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof LowStockAlert>;

const mockLowStockItems: InventoryLevel[] = [
  {
    id: '1',
    posProduct: {
      id: '1',
      name: 'Golf Tees (Pack)',
      sku: 'GT001',
      category: 'equipment',
    } as PosProduct,
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
  {
    id: '2',
    posProduct: {
      id: '2',
      name: 'Energy Drink',
      sku: 'ED001',
      category: 'beverage',
    } as PosProduct,
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
  {
    id: '3',
    posProduct: {
      id: '3',
      name: 'Water Bottle',
      sku: 'WB001',
      category: 'beverage',
    } as PosProduct,
    course: { id: '1', name: 'Main Course' },
    currentStock: 5,
    reservedStock: 2,
    availableStock: 3,
    reorderPoint: 12,
    reorderQuantity: 36,
    needsReorder: true,
    stockStatus: 'low_stock',
    averageCostCents: 100,
    lastCostCents: 110,
    stockValueCents: 500,
    lastCountedAt: '2024-01-20T11:20:00Z',
    lastCountedBy: { id: '1', firstName: 'John', lastName: 'Doe' },
  },
  {
    id: '4',
    posProduct: {
      id: '4',
      name: 'Snack Bar',
      sku: 'SB001',
      category: 'food',
    } as PosProduct,
    course: { id: '2', name: 'Pro Shop' },
    currentStock: 3,
    reservedStock: 0,
    availableStock: 3,
    reorderPoint: 10,
    reorderQuantity: 50,
    needsReorder: true,
    stockStatus: 'low_stock',
    averageCostCents: 75,
    lastCostCents: 80,
    stockValueCents: 225,
    lastCountedAt: '2024-01-22T13:30:00Z',
    lastCountedBy: { id: '2', firstName: 'Jane', lastName: 'Smith' },
  },
  {
    id: '5',
    posProduct: {
      id: '5',
      name: 'Golf Glove',
      sku: 'GG001',
      category: 'apparel',
    } as PosProduct,
    course: { id: '1', name: 'Main Course' },
    currentStock: 2,
    reservedStock: 1,
    availableStock: 1,
    reorderPoint: 6,
    reorderQuantity: 20,
    needsReorder: true,
    stockStatus: 'low_stock',
    averageCostCents: 1500,
    lastCostCents: 1600,
    stockValueCents: 3000,
    lastCountedAt: '2024-01-18T08:45:00Z',
    lastCountedBy: { id: '1', firstName: 'John', lastName: 'Doe' },
  },
];

export const Default: Story = {
  args: {
    lowStockItems: mockLowStockItems.slice(0, 3),
    onViewProduct: (productId: string) => {
      console.log('View product:', productId);
    },
    onDismiss: () => {
      console.log('Dismissed alert');
    },
  },
};

export const ManyItems: Story = {
  args: {
    lowStockItems: mockLowStockItems,
    onViewProduct: (productId: string) => {
      console.log('View product:', productId);
    },
    onDismiss: () => {
      console.log('Dismissed alert');
    },
  },
};

export const OutOfStockOnly: Story = {
  args: {
    lowStockItems: mockLowStockItems.filter(item => item.stockStatus === 'out_of_stock'),
    onViewProduct: (productId: string) => {
      console.log('View product:', productId);
    },
  },
};

export const LowStockOnly: Story = {
  args: {
    lowStockItems: mockLowStockItems.filter(item => item.stockStatus === 'low_stock'),
    onViewProduct: (productId: string) => {
      console.log('View product:', productId);
    },
  },
};

export const WithoutActions: Story = {
  args: {
    lowStockItems: mockLowStockItems.slice(0, 2),
  },
};