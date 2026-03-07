import type { Meta, StoryObj } from "@storybook/react";
import { MarketplaceSettingsPanel } from "./MarketplaceSettingsPanel";
import type { MarketplaceConnection } from "../../types";

const mockConnection: MarketplaceConnection = {
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
  course: {
    id: "1",
    name: "Pine Valley Golf Club",
    holes: 18,
    intervalMinutes: 8,
    slug: "pine-valley",
    maxPlayersPerSlot: 4,
  } as any,
  activeListingsCount: 24,
  totalListingsCount: 156,
  createdAt: "2026-01-15T00:00:00Z",
  updatedAt: new Date().toISOString(),
};

const meta: Meta<typeof MarketplaceSettingsPanel> = {
  title: "Marketplace/SettingsPanel",
  component: MarketplaceSettingsPanel,
  args: {
    onSave: (id, settings) => console.log("save", id, settings),
  },
};

export default meta;
type Story = StoryObj<typeof MarketplaceSettingsPanel>;

export const Default: Story = {
  args: {
    connection: mockConnection,
  },
};

export const Saving: Story = {
  args: {
    connection: mockConnection,
    saving: true,
  },
};

export const TeeOff: Story = {
  args: {
    connection: {
      ...mockConnection,
      provider: "teeoff",
      providerLabel: "TeeOff",
    },
  },
};
