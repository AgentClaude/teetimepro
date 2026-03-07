import type { Meta, StoryObj } from "@storybook/react";
import { MarketplaceListingsTable } from "./MarketplaceListingsTable";
import type { MarketplaceListing } from "../../types";

const mockListings: MarketplaceListing[] = [
  {
    id: "1",
    status: "listed",
    externalListingId: "gn_abc123",
    listedPriceCents: 6750,
    listedPriceCurrency: "USD",
    commissionRateBps: 1500,
    commissionRatePercent: 15.0,
    estimatedCommissionCents: 1013,
    netRevenueCents: 5737,
    listedAt: new Date().toISOString(),
    expiresAt: new Date(Date.now() + 86400000).toISOString(),
    teeTime: { id: "1", startsAt: new Date(Date.now() + 86400000).toISOString() } as any,
    providerLabel: "GolfNow",
    createdAt: new Date().toISOString(),
  },
  {
    id: "2",
    status: "booked",
    externalListingId: "gn_def456",
    listedPriceCents: 8500,
    listedPriceCurrency: "USD",
    commissionRateBps: 1500,
    commissionRatePercent: 15.0,
    estimatedCommissionCents: 1275,
    netRevenueCents: 7225,
    listedAt: new Date(Date.now() - 3600000).toISOString(),
    expiresAt: new Date(Date.now() + 172800000).toISOString(),
    teeTime: { id: "2", startsAt: new Date(Date.now() + 172800000).toISOString() } as any,
    providerLabel: "GolfNow",
    createdAt: new Date().toISOString(),
  },
  {
    id: "3",
    status: "expired",
    externalListingId: "to_ghi789",
    listedPriceCents: 5500,
    listedPriceCurrency: "USD",
    commissionRateBps: 1200,
    commissionRatePercent: 12.0,
    estimatedCommissionCents: 660,
    netRevenueCents: 4840,
    listedAt: new Date(Date.now() - 86400000).toISOString(),
    expiresAt: new Date(Date.now() - 3600000).toISOString(),
    teeTime: { id: "3", startsAt: new Date(Date.now() - 3600000).toISOString() } as any,
    providerLabel: "TeeOff",
    createdAt: new Date().toISOString(),
  },
];

const meta: Meta<typeof MarketplaceListingsTable> = {
  title: "Marketplace/ListingsTable",
  component: MarketplaceListingsTable,
};

export default meta;
type Story = StoryObj<typeof MarketplaceListingsTable>;

export const WithListings: Story = {
  args: {
    listings: mockListings,
  },
};

export const Empty: Story = {
  args: {
    listings: [],
  },
};

export const Loading: Story = {
  args: {
    listings: [],
    loading: true,
  },
};

export const SingleListing: Story = {
  args: {
    listings: [mockListings[0]],
  },
};
