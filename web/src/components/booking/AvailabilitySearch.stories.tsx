import type { Meta, StoryObj } from "@storybook/react";
import { AvailabilitySearch } from "./AvailabilitySearch";
import type { AvailableSlot, AvailabilitySearchResult } from "../../types";

const courses = [
  { id: "1", name: "Pine Valley Golf Club" },
  { id: "2", name: "Sunset Ridge Course" },
];

function mockSlot(overrides: Partial<AvailableSlot> = {}): AvailableSlot {
  return {
    teeTimeId: Math.random().toString(36).slice(2),
    courseId: "1",
    courseName: "Pine Valley Golf Club",
    date: "2026-03-08",
    startsAt: "2026-03-08T09:00:00Z",
    formattedTime: "9:00 AM",
    availableSpots: 4,
    maxPlayers: 4,
    bookedPlayers: 0,
    basePriceCents: 5000,
    dynamicPriceCents: 5000,
    pricePerPlayerCents: 5000,
    totalPriceCents: 10000,
    hasDynamicPricing: false,
    appliedRules: [],
    formattedBasePrice: "$50.00",
    formattedDynamicPrice: "$50.00",
    formattedTotalPrice: "$100.00",
    ...overrides,
  };
}

const morningSlots: AvailableSlot[] = [
  mockSlot({ formattedTime: "7:00 AM", availableSpots: 4, bookedPlayers: 0 }),
  mockSlot({ formattedTime: "7:10 AM", availableSpots: 3, bookedPlayers: 1 }),
  mockSlot({ formattedTime: "7:20 AM", availableSpots: 4, bookedPlayers: 0 }),
  mockSlot({
    formattedTime: "8:00 AM",
    availableSpots: 1,
    bookedPlayers: 3,
    basePriceCents: 5000,
    dynamicPriceCents: 6500,
    pricePerPlayerCents: 6500,
    totalPriceCents: 13000,
    hasDynamicPricing: true,
    appliedRules: ["Peak morning pricing"],
    formattedBasePrice: "$50.00",
    formattedDynamicPrice: "$65.00",
    formattedTotalPrice: "$130.00",
  }),
  mockSlot({ formattedTime: "8:10 AM", availableSpots: 2, bookedPlayers: 2 }),
  mockSlot({ formattedTime: "9:00 AM", availableSpots: 4, bookedPlayers: 0 }),
  mockSlot({ formattedTime: "9:10 AM", availableSpots: 4, bookedPlayers: 0 }),
  mockSlot({
    formattedTime: "10:00 AM",
    availableSpots: 4,
    bookedPlayers: 0,
    basePriceCents: 5000,
    dynamicPriceCents: 4000,
    pricePerPlayerCents: 4000,
    totalPriceCents: 8000,
    hasDynamicPricing: true,
    appliedRules: ["Off-peak discount"],
    formattedBasePrice: "$50.00",
    formattedDynamicPrice: "$40.00",
    formattedTotalPrice: "$80.00",
  }),
];

const singleDayResult: AvailabilitySearchResult = {
  slots: morningSlots,
  totalAvailable: morningSlots.length,
  dateRange: { startDate: "2026-03-08", endDate: "2026-03-08", days: 1 },
  filters: { players: 2, timePreference: null, courseId: null },
};

const multiDaySlots: AvailableSlot[] = [
  ...morningSlots,
  mockSlot({
    date: "2026-03-09",
    startsAt: "2026-03-09T09:00:00Z",
    formattedTime: "9:00 AM",
    availableSpots: 4,
  }),
  mockSlot({
    date: "2026-03-09",
    startsAt: "2026-03-09T10:00:00Z",
    formattedTime: "10:00 AM",
    availableSpots: 3,
    bookedPlayers: 1,
  }),
  mockSlot({
    date: "2026-03-09",
    startsAt: "2026-03-09T14:00:00Z",
    formattedTime: "2:00 PM",
    availableSpots: 4,
    basePriceCents: 4000,
    dynamicPriceCents: 3500,
    pricePerPlayerCents: 3500,
    totalPriceCents: 7000,
    hasDynamicPricing: true,
    appliedRules: ["Weekend afternoon special"],
    formattedBasePrice: "$40.00",
    formattedDynamicPrice: "$35.00",
    formattedTotalPrice: "$70.00",
  }),
];

const multiDayResult: AvailabilitySearchResult = {
  slots: multiDaySlots,
  totalAvailable: multiDaySlots.length,
  dateRange: { startDate: "2026-03-08", endDate: "2026-03-09", days: 2 },
  filters: { players: 2, timePreference: null, courseId: null },
};

const emptyResult: AvailabilitySearchResult = {
  slots: [],
  totalAvailable: 0,
  dateRange: { startDate: "2026-03-08", endDate: "2026-03-08", days: 1 },
  filters: { players: 4, timePreference: "morning", courseId: null },
};

const meta: Meta<typeof AvailabilitySearch> = {
  title: "Booking/AvailabilitySearch",
  component: AvailabilitySearch,
  args: {
    onSearch: () => {},
    onSelectSlot: () => {},
    courses,
  },
};

export default meta;
type Story = StoryObj<typeof AvailabilitySearch>;

export const SingleDay: Story = {
  args: {
    result: singleDayResult,
  },
};

export const MultiDay: Story = {
  args: {
    result: multiDayResult,
  },
};

export const Empty: Story = {
  args: {
    result: emptyResult,
  },
};

export const Loading: Story = {
  args: {
    result: null,
    loading: true,
  },
};

export const InitialState: Story = {
  args: {
    result: null,
    loading: false,
  },
};
