import type { Meta, StoryObj } from "@storybook/react";
import { CampaignStatusBadge } from "../components/campaigns/CampaignStatusBadge";

const meta: Meta<typeof CampaignStatusBadge> = {
  title: "Campaigns/CampaignStatusBadge",
  component: CampaignStatusBadge,
  tags: ["autodocs"],
  argTypes: {
    status: {
      control: "select",
      options: [
        "draft",
        "scheduled",
        "sending",
        "completed",
        "cancelled",
        "failed",
      ],
    },
  },
};

export default meta;
type Story = StoryObj<typeof CampaignStatusBadge>;

export const Draft: Story = { args: { status: "draft" } };
export const Scheduled: Story = { args: { status: "scheduled" } };
export const Sending: Story = { args: { status: "sending" } };
export const Completed: Story = { args: { status: "completed" } };
export const Cancelled: Story = { args: { status: "cancelled" } };
export const Failed: Story = { args: { status: "failed" } };

export const AllStatuses: Story = {
  render: () => (
    <div className="flex gap-2">
      {["draft", "scheduled", "sending", "completed", "cancelled", "failed"].map(
        (status) => (
          <CampaignStatusBadge key={status} status={status} />
        )
      )}
    </div>
  ),
};
