import type { Meta, StoryObj } from "@storybook/react";
import { MarketplaceConnectionCard } from "./MarketplaceConnectionCard";
import type { MarketplaceConnection, Course } from "../../types";

const mockCourse: Course = {
  id: "1",
  name: "Pine Valley Golf Club",
  holes: 18,
  intervalMinutes: 8,
  maxPlayersPerSlot: 4,
  firstTeeTime: "06:00",
  lastTeeTime: "18:00",
  weekdayRateCents: 15000,
  weekendRateCents: 20000,
  twilightRateCents: 10000,
  address: null,
  phone: null,
  voiceConfig: {},
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
  course: mockCourse,
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
