import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./Button";

const meta: Meta<typeof Button> = {
  title: "UI/Button",
  component: Button,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["primary", "secondary", "danger", "ghost", "outline"],
    },
    size: {
      control: "select",
      options: ["sm", "md", "lg"],
    },
    loading: { control: "boolean" },
    fullWidth: { control: "boolean" },
    disabled: { control: "boolean" },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    children: "Book Tee Time",
    variant: "primary",
  },
};

export const Secondary: Story = {
  args: {
    children: "Cancel",
    variant: "secondary",
  },
};

export const Danger: Story = {
  args: {
    children: "Delete Booking",
    variant: "danger",
  },
};

export const Ghost: Story = {
  args: {
    children: "View Details",
    variant: "ghost",
  },
};

export const Outline: Story = {
  args: {
    children: "Export",
    variant: "outline",
  },
};

export const Small: Story = {
  args: {
    children: "Edit",
    size: "sm",
  },
};

export const Large: Story = {
  args: {
    children: "Complete Registration",
    size: "lg",
  },
};

export const Loading: Story = {
  args: {
    children: "Processing...",
    loading: true,
  },
};

export const Disabled: Story = {
  args: {
    children: "Unavailable",
    disabled: true,
  },
};

export const FullWidth: Story = {
  args: {
    children: "Confirm Booking",
    fullWidth: true,
  },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-3">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="danger">Danger</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="outline">Outline</Button>
    </div>
  ),
};

export const AllSizes: Story = {
  render: () => (
    <div className="flex items-center gap-3">
      <Button size="sm">Small</Button>
      <Button size="md">Medium</Button>
      <Button size="lg">Large</Button>
    </div>
  ),
};
