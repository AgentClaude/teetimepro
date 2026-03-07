export interface LoyaltyProgram {
  id: string;
  name: string;
  description: string | null;
  pointsPerDollar: number;
  isActive: boolean;
  tierThresholds: Record<string, number>;
  createdAt: string;
  updatedAt: string;
}

export interface LoyaltyAccount {
  id: string;
  pointsBalance: number;
  lifetimePoints: number;
  tier: "bronze" | "silver" | "gold" | "platinum";
  tierName: string;
  pointsNeededForNextTier: number;
  createdAt: string;
  updatedAt: string;
  loyaltyProgram: LoyaltyProgram | null;
  recentTransactions: LoyaltyTransaction[];
}

export type LoyaltyTransactionType = "earn" | "redeem" | "adjust" | "expire";

export interface LoyaltyTransaction {
  id: string;
  transactionType: LoyaltyTransactionType;
  points: number;
  pointsDisplay: string;
  description: string;
  balanceAfter: number;
  transactionIcon: string;
  positive: boolean;
  negative: boolean;
  createdAt: string;
  sourceType: string | null;
  sourceId: string | null;
}

export type LoyaltyRewardTypeEnum =
  | "discount_percentage"
  | "discount_fixed"
  | "free_round"
  | "pro_shop_credit";

export interface LoyaltyReward {
  id: string;
  name: string;
  description: string | null;
  pointsCost: number;
  rewardType: LoyaltyRewardTypeEnum;
  discountValue: number | null;
  discountDisplay: string;
  isActive: boolean;
  maxRedemptionsPerUser: number | null;
  canBeRedeemed: boolean;
  remainingRedemptions: number | null;
  createdAt: string;
  updatedAt: string;
}

export type LoyaltyRedemptionStatus = "pending" | "applied" | "cancelled" | "expired";

export interface LoyaltyRedemption {
  id: string;
  status: LoyaltyRedemptionStatus;
  code: string;
  expiresAt: string | null;
  expired: boolean;
  canBeApplied: boolean;
  canBeCancelled: boolean;
  createdAt: string;
  updatedAt: string;
  loyaltyAccount: LoyaltyAccount;
  loyaltyReward: LoyaltyReward;
}
