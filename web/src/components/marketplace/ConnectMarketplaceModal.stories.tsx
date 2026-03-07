import type { Meta, StoryObj } from "@storybook/react";
import { ConnectMarketplaceModal } from "./ConnectMarketplaceModal";

const mockCourses = [
  { id: "1", name: "Pine Valley Golf Club", holes: 18, intervalMinutes: 8, slug: "pine-valley", maxPlayersPerSlot: 4 },
  { id: "2", name: "Augusta National", holes: 18, intervalMinutes: 10, slug: "augusta", maxPlayersPerSlot: 4 },
  { id: "3", name: "Pebble Beach", holes: 18, intervalMinutes: 8, slug: "pebble-beach", maxPlayersPerSlot: 4 },
];

const meta: Meta<typeof ConnectMarketplaceModal> = {
  title: "Marketplace/ConnectModal",
  component: ConnectMarketplaceModal,
  args: {
    isOpen: true,
    onClose: () => console.log("close"),
    onConnect: (data) => console.log("connect", data),
    courses: mockCourses as any,
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
