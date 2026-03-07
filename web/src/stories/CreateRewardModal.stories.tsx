import type { Meta, StoryObj } from "@storybook/react";
import { CreateRewardModal } from "../components/loyalty/CreateRewardModal";

const meta: Meta<typeof CreateRewardModal> = {
  title: "Loyalty/CreateRewardModal",
  component: CreateRewardModal,
  tags: ["autodocs"],
  decorators: [
    (Story: React.ComponentType) => (
      <div className="min-h-screen bg-gray-50">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof CreateRewardModal>;

export const Open: Story = {
  args: {
    isOpen: true,
    onClose: () => console.log("Close"),
    onCreateReward: async (data) => {
      console.log("Create reward:", data);
      await new Promise((resolve) => setTimeout(resolve, 1000));
    },
  },
};

export const Loading: Story = {
  args: {
    isOpen: true,
    onClose: () => console.log("Close"),
    onCreateReward: async (data) => {
      console.log("Create reward:", data);
      await new Promise((resolve) => setTimeout(resolve, 5000));
    },
    isLoading: true,
  },
};

export const Closed: Story = {
  args: {
    isOpen: false,
    onClose: () => console.log("Close"),
    onCreateReward: async () => {},
  },
};
