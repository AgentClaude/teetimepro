export interface Course {
  id: string;
  name: string;
  slug: string;
  holes: number;
  address: string | null;
  phone: string | null;
  weekdayRateCents: number | null;
  weekendRateCents: number | null;
  twilightRateCents: number | null;
  intervalMinutes: number;
  maxPlayersPerSlot: number;
  firstTeeTime: string;
  lastTeeTime: string;
}

export interface TeeTime {
  id: string;
  startsAt: string;
  formattedTime: string;
  status: string;
  maxPlayers: number;
  bookedPlayers: number;
  availableSpots: number;
  priceCents: number | null;
  price: string | null;
  dynamicPriceCents: number | null;
  dynamicPrice: string | null;
  hasDynamicPricing: boolean;
}

export interface Booking {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalCents: number;
  cancellable: boolean;
  notes: string | null;
  createdAt: string;
  teeTime: {
    id: string;
    startsAt: string;
    formattedTime: string;
    teeSheetId?: string;
  };
}

export type TimePreference = 'morning' | 'afternoon' | 'twilight' | null;
