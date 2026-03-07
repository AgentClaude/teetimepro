export interface PosProduct {
  id: string;
  name: string;
  sku: string;
  barcode: string | null;
  priceCents: number;
  category: PosProductCategory;
  description: string | null;
  active: boolean;
  trackInventory: boolean;
  stockQuantity: number | null;
  inStock: boolean;
  formattedPrice: string;
  inventoryLevels: InventoryLevel[];
  inventoryMovements: InventoryMovement[];
  needsReorder: boolean;
}

export interface InventoryLevel {
  id: string;
  posProduct: PosProduct;
  course: {
    id: string;
    name: string;
  };
  currentStock: number;
  reservedStock: number;
  availableStock: number;
  reorderPoint: number;
  reorderQuantity: number;
  needsReorder: boolean;
  stockStatus: 'in_stock' | 'low_stock' | 'out_of_stock';
  averageCostCents: number | null;
  lastCostCents: number | null;
  stockValueCents: number;
  lastCountedAt: string | null;
  lastCountedBy: {
    id: string;
    firstName: string;
    lastName: string;
  } | null;
}

export interface InventoryMovement {
  id: string;
  posProduct: PosProduct;
  course: {
    id: string;
    name: string;
  };
  performedBy: {
    id: string;
    firstName: string;
    lastName: string;
  };
  movementType: 'receipt' | 'sale' | 'adjustment' | 'transfer_in' | 'transfer_out';
  quantity: number;
  formattedQuantity: string;
  unitCostCents: number | null;
  totalCostCents: number | null;
  notes: string | null;
  referenceType: string | null;
  referenceId: string | null;
  createdAt: string;
}

export type PosProductCategory =
  | 'food'
  | 'beverage'
  | 'apparel'
  | 'equipment'
  | 'rental'
  | 'other';

export interface CartItem {
  product: PosProduct;
  quantity: number;
}

export interface PosSaleItemInput {
  productId: string;
  quantity: number;
}

export const CATEGORY_LABELS: Record<PosProductCategory, string> = {
  food: 'Food',
  beverage: 'Beverages',
  apparel: 'Apparel',
  equipment: 'Equipment',
  rental: 'Rentals',
  other: 'Other',
};

export const CATEGORY_ICONS: Record<PosProductCategory, string> = {
  food: '🍔',
  beverage: '🍺',
  apparel: '👕',
  equipment: '⛳',
  rental: '🏌️',
  other: '📦',
};
