import React from "react";
import type { Meta, StoryObj } from "@storybook/react";
import { CampaignProgressBar } from "../components/campaigns/CampaignProgressBar";

const meta: Meta<typeof CampaignProgressBar> = {
  title: "Campaigns/CampaignProgressBar",
  component: CampaignProgressBar,
  tags: ["autodocs"],
  decorators: [
    (Story: React.ComponentType) => (
      <div className="max-w-md">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof CampaignProgressBar>;

export const Empty: Story = {
  args: {
    totalRecipients: 0,
    sentCount: 0,
    deliveredCount: 0,
    failedCount: 0,
    progressPercentage: 0,
  },
};

export const InProgress: Story = {
  args: {
    totalRecipients: 100,
    sentCount: 45,
    deliveredCount: 40,
    failedCount: 5,
    progressPercentage: 45,
  },
};

export const MostlyComplete: Story = {
  args: {
    totalRecipients: 200,
    sentCount: 185,
    deliveredCount: 180,
    failedCount: 12,
    progressPercentage: 96,
  },
};

export const AllDelivered: Story = {
  args: {
    totalRecipients: 50,
    sentCount: 50,
    deliveredCount: 50,
    failedCount: 0,
    progressPercentage: 100,
  },
};

export const HighFailureRate: Story = {
  args: {
    totalRecipients: 30,
    sentCount: 30,
    deliveredCount: 15,
    failedCount: 15,
    progressPercentage: 100,
  },
};
