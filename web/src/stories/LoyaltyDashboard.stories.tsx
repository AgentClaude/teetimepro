import type { Meta, StoryObj } from "@storybook/react";
import { LoyaltyDashboard } from "../components/loyalty/LoyaltyDashboard";
import type { LoyaltyAccount, LoyaltyProgram, LoyaltyReward, LoyaltyTransaction } from "../types/loyalty";

const meta: Meta<typeof LoyaltyDashboard> = {
  title: "Loyalty/LoyaltyDashboard",
  component: LoyaltyDashboard,
  tags: ["autodocs"],
  decorators: [
    (Story: React.ComponentType) => (
      <div className="mx-auto max-w-4xl p-6 bg-gray-50 min-h-screen">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof LoyaltyDashboard>;

const baseProgram: LoyaltyProgram = {
  id: "prog-1",
  name: "Eagle Rewards",
  description: "Earn points on every round and redeem for exclusive rewards!",
  pointsPerDollar: 10,
  isActive: true,
  tierThresholds: { silver: 1000, gold: 5000, platinum: 15000 },
  createdAt: "2026-01-01T00:00:00Z",
  updatedAt: "2026-01-01T00:00:00Z",
};

const recentTransactions: LoyaltyTransaction[] = [
  {
    id: "tx-1",
    transactionType: "earn",
    points: 550,
    pointsDisplay: "+550",
    description: "18-hole round booked",
    balanceAfter: 2750,
    transactionIcon: "⛳",
    positive: true,
    negative: false,
    createdAt: "2026-03-06T14:00:00Z",
    sourceType: "Booking",
    sourceId: "b-123",
  },
  {
    id: "tx-2",
    transactionType: "redeem",
    points: -500,
    pointsDisplay: "-500",
    description: "Redeemed: 10% Off Next Round",
    balanceAfter: 2200,
    transactionIcon: "🎁",
    positive: false,
    negative: true,
    createdAt: "2026-03-05T10:30:00Z",
    sourceType: "LoyaltyReward",
    sourceId: "r-1",
  },
  {
    id: "tx-3",
    transactionType: "earn",
    points: 800,
    pointsDisplay: "+800",
    description: "Pro shop purchase",
    balanceAfter: 2700,
    transactionIcon: "🛍️",
    positive: true,
    negative: false,
    createdAt: "2026-03-04T16:00:00Z",
    sourceType: null,
    sourceId: null,
  },
];

const baseAccount: LoyaltyAccount = {
  id: "acc-1",
  pointsBalance: 2750,
  lifetimePoints: 8500,
  tier: "gold",
  tierName: "Gold Member",
  pointsNeededForNextTier: 6500,
  createdAt: "2026-01-15T00:00:00Z",
  updatedAt: "2026-03-06T14:00:00Z",
  loyaltyProgram: baseProgram,
  recentTransactions,
};

const availableRewards: LoyaltyReward[] = [
  {
    id: "r-1",
    name: "10% Off Next Round",
    description: "Save 10% on your next tee time booking",
    pointsCost: 500,
    rewardType: "discount_percentage",
    discountValue: 10,
    discountDisplay: "10% off",
    isActive: true,
    maxRedemptionsPerUser: 3,
    canBeRedeemed: true,
    remainingRedemptions: 2,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
  },
  {
    id: "r-2",
    name: "Free Round of Golf",
    description: "One complimentary 18-hole round",
    pointsCost: 5000,
    rewardType: "free_round",
    discountValue: null,
    discountDisplay: "Free round",
    isActive: true,
    maxRedemptionsPerUser: 1,
    canBeRedeemed: false,
    remainingRedemptions: 1,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
  },
  {
    id: "r-3",
    name: "$20 Pro Shop Credit",
    description: "Use towards any pro shop purchase",
    pointsCost: 1500,
    rewardType: "pro_shop_credit",
    discountValue: 2000,
    discountDisplay: "$20.00 credit",
    isActive: true,
    maxRedemptionsPerUser: null,
    canBeRedeemed: true,
    remainingRedemptions: null,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
  },
];

export const GoldTier: Story = {
  args: {
    loyaltyProgram: baseProgram,
    loyaltyAccount: baseAccount,
    availableRewards,
    onRedeemReward: (id: string) => console.log("Redeem:", id),
    onViewTransactions: () => console.log("View transactions"),
  },
};

export const PlatinumTier: Story = {
  args: {
    loyaltyProgram: baseProgram,
    loyaltyAccount: {
      ...baseAccount,
      tier: "platinum" as const,
      tierName: "Platinum Member",
      pointsBalance: 18000,
      lifetimePoints: 25000,
      pointsNeededForNextTier: 0,
    },
    availableRewards,
  },
};

export const BronzeTierNewMember: Story = {
  args: {
    loyaltyProgram: baseProgram,
    loyaltyAccount: {
      ...baseAccount,
      tier: "bronze" as const,
      tierName: "Bronze Member",
      pointsBalance: 150,
      lifetimePoints: 150,
      pointsNeededForNextTier: 850,
      recentTransactions: [recentTransactions[0]],
    },
    availableRewards,
  },
};

export const NoAccount: Story = {
  args: {
    loyaltyProgram: baseProgram,
    loyaltyAccount: null,
    availableRewards: [],
  },
};

export const NoProgram: Story = {
  args: {
    loyaltyProgram: null,
    loyaltyAccount: null,
    availableRewards: [],
  },
};

export const Loading: Story = {
  args: {
    loyaltyProgram: null,
    loyaltyAccount: null,
    availableRewards: [],
    isLoading: true,
  },
};

export const NoRewards: Story = {
  args: {
    loyaltyProgram: baseProgram,
    loyaltyAccount: baseAccount,
    availableRewards: [],
  },
};
