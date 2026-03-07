import type { Meta, StoryObj } from "@storybook/react";
import { LoadingSpinner } from "./LoadingSpinner";

const meta: Meta<typeof LoadingSpinner> = {
  title: "UI/LoadingSpinner",
  component: LoadingSpinner,
  tags: ["autodocs"],
  argTypes: {
    size: {
      control: "select",
      options: ["sm", "md", "lg"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof LoadingSpinner>;

export const Default: Story = {};

export const Small: Story = {
  args: { size: "sm" },
};

export const Medium: Story = {
  args: { size: "md" },
};

export const Large: Story = {
  args: { size: "lg" },
};

export const AllSizes: Story = {
  render: () => (
    <div className="flex items-center gap-6">
      <div className="text-center">
        <LoadingSpinner size="sm" />
        <p className="text-xs text-rough-500 mt-2">Small</p>
      </div>
      <div className="text-center">
        <LoadingSpinner size="md" />
        <p className="text-xs text-rough-500 mt-2">Medium</p>
      </div>
      <div className="text-center">
        <LoadingSpinner size="lg" />
        <p className="text-xs text-rough-500 mt-2">Large</p>
      </div>
    </div>
  ),
};

export const InContext: Story = {
  name: "Loading State",
  render: () => (
    <div className="flex items-center justify-center p-12 bg-rough-50 rounded-xl">
      <div className="text-center">
        <LoadingSpinner size="lg" />
        <p className="text-sm text-rough-500 mt-3">Loading tee sheet...</p>
      </div>
    </div>
  ),
};
