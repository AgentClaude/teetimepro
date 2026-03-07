import type { PosProduct } from './pos';

export interface TurnOrderItem {
  id: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
  totalCents: number;
  category: string;
}

export interface TurnOrder {
  id: string;
  golferName: string;
  totalCents: number;
  status: string;
  turnOrder: boolean;
  deliveryHole: number | null;
  deliveryNotes: string | null;
  openedAt: string;
  booking: {
    id: string;
    confirmationCode: string;
    teeTime: {
      formattedTime: string;
    };
  } | null;
  fnbTabItems: TurnOrderItem[];
}

export interface TurnOrderCartItem {
  product: PosProduct;
  quantity: number;
}
