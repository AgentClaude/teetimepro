import type { Meta, StoryObj } from "@storybook/react";
import { MarketplaceConnectionCard } from "./MarketplaceConnectionCard";
import type { MarketplaceConnection } from "../../types";

const mockCourse = {
  id: "1",
  name: "Pine Valley Golf Club",
  holes: 18,
  intervalMinutes: 8,
  slug: "pine-valley",
  maxPlayersPerSlot: 4,
};

const baseConnection: MarketplaceConnection = {
  id: "1",
  provider: "golfnow",
  providerLabel: "GolfNow",
  status: "active",
  externalCourseId: "gn_12345",
  settings: {
    auto_syndicate: true,
    min_advance_hours: 4,
    max_advance_days: 14,
    discount_percent: 10,
    blocked_time_ranges: [],
    min_available_spots: 1,
  },
  effectiveSettings: {
    auto_syndicate: true,
    min_advance_hours: 4,
    max_advance_days: 14,
    discount_percent: 10,
    blocked_time_ranges: [],
    min_available_spots: 1,
  },
  lastSyncedAt: new Date().toISOString(),
  lastError: null,
  course: mockCourse as any,
  activeListingsCount: 24,
  totalListingsCount: 156,
  createdAt: "2026-01-15T00:00:00Z",
  updatedAt: new Date().toISOString(),
};

const meta: Meta<typeof MarketplaceConnectionCard> = {
  title: "Marketplace/ConnectionCard",
  component: MarketplaceConnectionCard,
  args: {
    onSync: () => console.log("sync"),
    onPause: () => console.log("pause"),
    onResume: () => console.log("resume"),
    onDisconnect: () => console.log("disconnect"),
    onSettings: () => console.log("settings"),
  },
};

export default meta;
type Story = StoryObj<typeof MarketplaceConnectionCard>;

export const Active: Story = {
  args: {
    connection: baseConnection,
  },
};

export const ActiveWithDiscount: Story = {
  args: {
    connection: {
      ...baseConnection,
      effectiveSettings: { ...baseConnection.effectiveSettings, discount_percent: 15 },
    },
  },
};

export const Paused: Story = {
  args: {
    connection: { ...baseConnection, status: "paused", activeListingsCount: 0 },
  },
};

export const Error: Story = {
  args: {
    connection: {
      ...baseConnection,
      status: "error",
      lastError: "API authentication failed: Invalid API key",
      activeListingsCount: 0,
    },
  },
};

export const TeeOff: Story = {
  args: {
    connection: {
      ...baseConnection,
      provider: "teeoff",
      providerLabel: "TeeOff",
      activeListingsCount: 12,
      totalListingsCount: 89,
    },
  },
};

export const Syncing: Story = {
  args: {
    connection: baseConnection,
    syncing: true,
  },
};

export const NeverSynced: Story = {
  args: {
    connection: {
      ...baseConnection,
      status: "pending",
      lastSyncedAt: null,
      activeListingsCount: 0,
      totalListingsCount: 0,
    },
  },
};
