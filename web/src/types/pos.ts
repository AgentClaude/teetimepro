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
