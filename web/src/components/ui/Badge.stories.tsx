import type { Meta, StoryObj } from "@storybook/react";
import { Badge, statusBadgeVariant } from "./Badge";

const meta: Meta<typeof Badge> = {
  title: "UI/Badge",
  component: Badge,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["default", "success", "warning", "danger", "info", "neutral"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Badge>;

export const Default: Story = {
  args: {
    children: "Available",
    variant: "default",
  },
};

export const Success: Story = {
  args: {
    children: "Confirmed",
    variant: "success",
  },
};

export const Warning: Story = {
  args: {
    children: "Partially Booked",
    variant: "warning",
  },
};

export const Danger: Story = {
  args: {
    children: "Cancelled",
    variant: "danger",
  },
};

export const Info: Story = {
  args: {
    children: "Checked In",
    variant: "info",
  },
};

export const Neutral: Story = {
  args: {
    children: "Maintenance",
    variant: "neutral",
  },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-2">
      <Badge variant="default">Default</Badge>
      <Badge variant="success">Success</Badge>
      <Badge variant="warning">Warning</Badge>
      <Badge variant="danger">Danger</Badge>
      <Badge variant="info">Info</Badge>
      <Badge variant="neutral">Neutral</Badge>
    </div>
  ),
};

export const BookingStatuses: Story = {
  name: "Booking Status Badges",
  render: () => {
    const statuses = [
      "available",
      "partially_booked",
      "fully_booked",
      "blocked",
      "maintenance",
      "confirmed",
      "checked_in",
      "cancelled",
      "no_show",
    ];
    return (
      <div className="flex flex-wrap gap-2">
        {statuses.map((status) => (
          <Badge key={status} variant={statusBadgeVariant(status)}>
            {status.replace(/_/g, " ")}
          </Badge>
        ))}
      </div>
    );
  },
};
