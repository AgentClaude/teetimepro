import type { Meta, StoryObj } from "@storybook/react";
import { Card, CardHeader } from "./Card";
import { Button } from "./Button";
import { Badge } from "./Badge";

const meta: Meta<typeof Card> = {
  title: "UI/Card",
  component: Card,
  tags: ["autodocs"],
  argTypes: {
    padding: {
      control: "select",
      options: ["none", "sm", "md", "lg"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Card>;

export const Default: Story = {
  args: {
    children: (
      <div>
        <h3 className="text-lg font-semibold text-rough-900">Tee Sheet</h3>
        <p className="text-sm text-rough-500 mt-1">
          Manage today&apos;s tee times and bookings.
        </p>
      </div>
    ),
  },
};

export const WithHeader: Story = {
  render: () => (
    <Card>
      <CardHeader
        title="Today's Bookings"
        subtitle="March 7, 2026"
        action={<Button size="sm">Add Booking</Button>}
      />
      <div className="space-y-2">
        <div className="flex justify-between items-center py-2 border-b border-rough-100">
          <span className="text-sm text-rough-700">7:00 AM — J. Smith</span>
          <Badge variant="success">Confirmed</Badge>
        </div>
        <div className="flex justify-between items-center py-2 border-b border-rough-100">
          <span className="text-sm text-rough-700">7:08 AM — M. Johnson</span>
          <Badge variant="info">Checked In</Badge>
        </div>
        <div className="flex justify-between items-center py-2">
          <span className="text-sm text-rough-700">7:16 AM — Available</span>
          <Badge variant="default">Open</Badge>
        </div>
      </div>
    </Card>
  ),
};

export const SmallPadding: Story = {
  args: {
    padding: "sm",
    children: <p className="text-sm text-rough-600">Compact card content.</p>,
  },
};

export const LargePadding: Story = {
  args: {
    padding: "lg",
    children: (
      <p className="text-rough-600">Spacious card with extra breathing room.</p>
    ),
  },
};

export const NoPadding: Story = {
  args: {
    padding: "none",
    children: (
      <div className="divide-y divide-rough-200">
        <div className="p-4">Row 1</div>
        <div className="p-4">Row 2</div>
        <div className="p-4">Row 3</div>
      </div>
    ),
  },
};

export const StatCard: Story = {
  render: () => (
    <div className="grid grid-cols-3 gap-4 max-w-2xl">
      <Card>
        <p className="text-sm text-rough-500">Today&apos;s Revenue</p>
        <p className="text-2xl font-bold text-rough-900 mt-1">$4,280</p>
        <p className="text-xs text-green-600 mt-1">+12% from yesterday</p>
      </Card>
      <Card>
        <p className="text-sm text-rough-500">Bookings</p>
        <p className="text-2xl font-bold text-rough-900 mt-1">47</p>
        <p className="text-xs text-rough-500 mt-1">of 72 slots</p>
      </Card>
      <Card>
        <p className="text-sm text-rough-500">Utilization</p>
        <p className="text-2xl font-bold text-rough-900 mt-1">65%</p>
        <p className="text-xs text-yellow-600 mt-1">Below target (75%)</p>
      </Card>
    </div>
  ),
};
