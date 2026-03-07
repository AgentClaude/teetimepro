import type { Meta, StoryObj } from "@storybook/react";
import { ConnectMarketplaceModal } from "./ConnectMarketplaceModal";
import type { Course } from "../../types";

const mockVoiceConfig = {};

const mockCourses: Course[] = [
  { id: "1", name: "Pine Valley Golf Club", holes: 18, intervalMinutes: 8, maxPlayersPerSlot: 4, firstTeeTime: "06:00", lastTeeTime: "18:00", weekdayRateCents: 15000, weekendRateCents: 20000, twilightRateCents: 10000, address: null, phone: null, voiceConfig: mockVoiceConfig },
  { id: "2", name: "Augusta National", holes: 18, intervalMinutes: 10, maxPlayersPerSlot: 4, firstTeeTime: "07:00", lastTeeTime: "17:00", weekdayRateCents: 25000, weekendRateCents: 35000, twilightRateCents: 18000, address: null, phone: null, voiceConfig: mockVoiceConfig },
  { id: "3", name: "Pebble Beach", holes: 18, intervalMinutes: 8, maxPlayersPerSlot: 4, firstTeeTime: "06:30", lastTeeTime: "18:30", weekdayRateCents: 20000, weekendRateCents: 30000, twilightRateCents: 15000, address: null, phone: null, voiceConfig: mockVoiceConfig },
];

const meta: Meta<typeof ConnectMarketplaceModal> = {
  title: "Marketplace/ConnectModal",
  component: ConnectMarketplaceModal,
  args: {
    isOpen: true,
    onClose: () => console.log("close"),
    onConnect: (data) => console.log("connect", data),
    courses: mockCourses,
  },
};

export default meta;
type Story = StoryObj<typeof ConnectMarketplaceModal>;

export const Default: Story = {};

export const Connecting: Story = {
  args: {
    connecting: true,
  },
};
