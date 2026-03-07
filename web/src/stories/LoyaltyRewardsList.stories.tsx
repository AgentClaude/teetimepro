import type { Meta, StoryObj } from "@storybook/react";
import { LoyaltyRewardsList } from "../components/loyalty/LoyaltyRewardsList";
import type { LoyaltyAccount, LoyaltyReward } from "../types/loyalty";

const meta: Meta<typeof LoyaltyRewardsList> = {
  title: "Loyalty/LoyaltyRewardsList",
  component: LoyaltyRewardsList,
  tags: ["autodocs"],
  decorators: [
    (Story: React.ComponentType) => (
      <div className="mx-auto max-w-5xl p-6 bg-gray-50 min-h-screen">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof LoyaltyRewardsList>;

const account: LoyaltyAccount = {
  id: "acc-1",
  pointsBalance: 2750,
  lifetimePoints: 8500,
  tier: "gold",
  tierName: "Gold Member",
  pointsNeededForNextTier: 6500,
  createdAt: "2026-01-15T00:00:00Z",
  updatedAt: "2026-03-06T14:00:00Z",
  loyaltyProgram: null,
  recentTransactions: [],
};

const rewards: LoyaltyReward[] = [
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
    name: "$10 Off Any Round",
    description: "Flat $10 discount on any tee time",
    pointsCost: 800,
    rewardType: "discount_fixed",
    discountValue: 1000,
    discountDisplay: "$10.00 off",
    isActive: true,
    maxRedemptionsPerUser: null,
    canBeRedeemed: true,
    remainingRedemptions: null,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
  },
  {
    id: "r-3",
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
    id: "r-4",
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
  {
    id: "r-5",
    name: "$50 Pro Shop Credit",
    description: "Premium pro shop credit for loyal members",
    pointsCost: 3500,
    rewardType: "pro_shop_credit",
    discountValue: 5000,
    discountDisplay: "$50.00 credit",
    isActive: true,
    maxRedemptionsPerUser: 2,
    canBeRedeemed: false,
    remainingRedemptions: 2,
    createdAt: "2026-01-01T00:00:00Z",
    updatedAt: "2026-01-01T00:00:00Z",
  },
];

export const Default: Story = {
  args: {
    rewards,
    loyaltyAccount: account,
    onRedeemReward: (id: string) => console.log("Redeem:", id),
    onToggleAffordableFilter: () => console.log("Toggle filter"),
  },
};

export const AffordableOnly: Story = {
  args: {
    rewards,
    loyaltyAccount: account,
    showAffordableOnly: true,
    onRedeemReward: (id: string) => console.log("Redeem:", id),
    onToggleAffordableFilter: () => console.log("Toggle filter"),
  },
};

export const LowPoints: Story = {
  args: {
    rewards,
    loyaltyAccount: { ...account, pointsBalance: 200 },
    onRedeemReward: (id: string) => console.log("Redeem:", id),
  },
};

export const NoAccount: Story = {
  args: {
    rewards,
    loyaltyAccount: null,
  },
};

export const EmptyRewards: Story = {
  args: {
    rewards: [],
    loyaltyAccount: account,
  },
};

export const Loading: Story = {
  args: {
    rewards: [],
    loyaltyAccount: null,
    isLoading: true,
  },
};
