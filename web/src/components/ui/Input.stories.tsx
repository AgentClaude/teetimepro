import type { Meta, StoryObj } from "@storybook/react";
import { Input } from "./Input";

const meta: Meta<typeof Input> = {
  title: "UI/Input",
  component: Input,
  tags: ["autodocs"],
  argTypes: {
    type: {
      control: "select",
      options: ["text", "email", "password", "number", "tel", "date", "time"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Input>;

export const Default: Story = {
  args: {
    placeholder: "Enter golfer name...",
  },
};

export const WithLabel: Story = {
  args: {
    label: "Email Address",
    id: "email",
    type: "email",
    placeholder: "golfer@example.com",
  },
};

export const WithError: Story = {
  args: {
    label: "Phone Number",
    id: "phone",
    type: "tel",
    placeholder: "(555) 123-4567",
    error: "Please enter a valid phone number",
    defaultValue: "abc",
  },
};

export const Disabled: Story = {
  args: {
    label: "Course Name",
    id: "course",
    defaultValue: "Pine Valley Golf Club",
    disabled: true,
  },
};

export const DateInput: Story = {
  args: {
    label: "Booking Date",
    id: "date",
    type: "date",
  },
};

export const TimeInput: Story = {
  args: {
    label: "Tee Time",
    id: "time",
    type: "time",
  },
};

export const NumberInput: Story = {
  args: {
    label: "Number of Players",
    id: "players",
    type: "number",
    min: 1,
    max: 4,
    defaultValue: 4,
  },
};

export const FormExample: Story = {
  name: "Form Layout",
  render: () => (
    <div className="max-w-md space-y-4">
      <Input label="Golfer Name" id="name" placeholder="John Smith" />
      <Input
        label="Email"
        id="email"
        type="email"
        placeholder="john@example.com"
      />
      <Input label="Phone" id="phone" type="tel" placeholder="(555) 123-4567" />
      <Input label="Handicap" id="handicap" type="number" placeholder="0-54" />
    </div>
  ),
};
