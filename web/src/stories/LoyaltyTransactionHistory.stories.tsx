import type { Meta, StoryObj } from "@storybook/react";
import { LoyaltyTransactionHistory } from "../components/loyalty/LoyaltyTransactionHistory";
import type { LoyaltyTransaction } from "../types/loyalty";

const meta: Meta<typeof LoyaltyTransactionHistory> = {
  title: "Loyalty/LoyaltyTransactionHistory",
  component: LoyaltyTransactionHistory,
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
type Story = StoryObj<typeof LoyaltyTransactionHistory>;

const transactions: LoyaltyTransaction[] = [
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
    createdAt: "2026-03-07T14:00:00Z",
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
    createdAt: "2026-03-07T10:30:00Z",
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
    createdAt: "2026-03-06T16:00:00Z",
    sourceType: null,
    sourceId: null,
  },
  {
    id: "tx-4",
    transactionType: "adjust",
    points: 200,
    pointsDisplay: "+200",
    description: "Bonus points: Member anniversary",
    balanceAfter: 1900,
    transactionIcon: "⚙️",
    positive: true,
    negative: false,
    createdAt: "2026-03-06T09:00:00Z",
    sourceType: "User",
    sourceId: "u-admin",
  },
  {
    id: "tx-5",
    transactionType: "earn",
    points: 450,
    pointsDisplay: "+450",
    description: "9-hole twilight round",
    balanceAfter: 1700,
    transactionIcon: "⛳",
    positive: true,
    negative: false,
    createdAt: "2026-03-05T18:30:00Z",
    sourceType: "Booking",
    sourceId: "b-120",
  },
  {
    id: "tx-6",
    transactionType: "redeem",
    points: -1500,
    pointsDisplay: "-1,500",
    description: "Redeemed: $20 Pro Shop Credit",
    balanceAfter: 1250,
    transactionIcon: "🎁",
    positive: false,
    negative: true,
    createdAt: "2026-03-04T11:00:00Z",
    sourceType: "LoyaltyReward",
    sourceId: "r-3",
  },
];

export const Default: Story = {
  args: {
    transactions,
    hasNextPage: true,
    onLoadMore: () => console.log("Load more"),
  },
};

export const SingleDay: Story = {
  args: {
    transactions: transactions.slice(0, 2),
  },
};

export const WithPagination: Story = {
  args: {
    transactions,
    hasNextPage: true,
    onLoadMore: () => console.log("Load more"),
    isLoadingMore: false,
  },
};

export const LoadingMore: Story = {
  args: {
    transactions,
    hasNextPage: true,
    onLoadMore: () => console.log("Load more"),
    isLoadingMore: true,
  },
};

export const Empty: Story = {
  args: {
    transactions: [],
  },
};

export const Loading: Story = {
  args: {
    transactions: [],
    isLoading: true,
  },
};
