export interface MemberAccountCharge {
  id: string;
  chargeType: 'fnb' | 'booking' | 'pro_shop' | 'dues' | 'other';
  status: 'pending' | 'posted' | 'voided' | 'paid';
  amountCents: number;
  amountCurrency: string;
  description: string;
  notes?: string;
  postedAt?: string;
  voidedAt?: string;
  createdAt: string;
  memberName?: string;
  voidable: boolean;
  chargedBy: {
    fullName: string;
  };
  membership: {
    id: string;
    user: {
      fullName: string;
    };
  };
  fnbTab?: {
    id: string;
    golferName: string;
  };
}

export interface MembershipAccount {
  id: string;
  tier: string;
  status: string;
  accountBalanceCents: number;
  creditLimitCents: number;
  availableCreditCents: number;
  startsAt: string;
  endsAt: string;
  user: {
    id: string;
    fullName: string;
    email: string;
  };
  recentCharges: MemberAccountCharge[];
}

export interface MemberAccountStatement {
  membership: MembershipAccount;
  charges: MemberAccountCharge[];
  totalCount: number;
  currentBalanceCents: number;
  creditLimitCents: number;
  availableCreditCents: number;
  periodTotalCents: number;
  page: number;
  perPage: number;
  totalPages: number;
}

export const CHARGE_TYPE_LABELS: Record<string, string> = {
  fnb: 'F&B',
  booking: 'Booking',
  pro_shop: 'Pro Shop',
  dues: 'Dues',
  other: 'Other',
};

export const STATUS_LABELS: Record<string, string> = {
  pending: 'Pending',
  posted: 'Posted',
  voided: 'Voided',
  paid: 'Paid',
};
