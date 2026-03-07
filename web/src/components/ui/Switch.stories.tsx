import { useState } from "react";
import type { Meta, StoryObj } from "@storybook/react";
import { Switch } from "./Switch";

const meta: Meta<typeof Switch> = {
  title: "UI/Switch",
  component: Switch,
  tags: ["autodocs"],
  argTypes: {
    size: {
      control: "select",
      options: ["sm", "md"],
    },
    checked: { control: "boolean" },
    disabled: { control: "boolean" },
  },
};

export default meta;
type Story = StoryObj<typeof Switch>;

export const Default: Story = {
  args: {
    checked: false,
    onCheckedChange: () => {},
  },
};

export const Checked: Story = {
  args: {
    checked: true,
    onCheckedChange: () => {},
  },
};

export const Small: Story = {
  args: {
    checked: true,
    size: "sm",
    onCheckedChange: () => {},
  },
};

export const Disabled: Story = {
  args: {
    checked: false,
    disabled: true,
    onCheckedChange: () => {},
  },
};

export const DisabledChecked: Story = {
  args: {
    checked: true,
    disabled: true,
    onCheckedChange: () => {},
  },
};

export const Interactive: Story = {
  render: () => {
    const InteractiveSwitch = () => {
      const [checked, setChecked] = useState(false);
      return (
        <div className="flex items-center gap-3">
          <Switch checked={checked} onCheckedChange={setChecked} />
          <span className="text-sm text-rough-700">
            {checked ? "Enabled" : "Disabled"}
          </span>
        </div>
      );
    };
    return <InteractiveSwitch />;
  },
};

export const SettingsExample: Story = {
  name: "Settings Panel",
  render: () => {
    const SettingsPanel = () => {
      const [emailNotif, setEmailNotif] = useState(true);
      const [smsNotif, setSmsNotif] = useState(false);
      const [autoConfirm, setAutoConfirm] = useState(true);
      const [waitlist, setWaitlist] = useState(false);

      return (
        <div className="max-w-sm space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-rough-900">
                Email Notifications
              </p>
              <p className="text-xs text-rough-500">
                Send booking confirmations via email
              </p>
            </div>
            <Switch checked={emailNotif} onCheckedChange={setEmailNotif} />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-rough-900">
                SMS Reminders
              </p>
              <p className="text-xs text-rough-500">
                Text reminders 24h before tee time
              </p>
            </div>
            <Switch checked={smsNotif} onCheckedChange={setSmsNotif} />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-rough-900">
                Auto-Confirm
              </p>
              <p className="text-xs text-rough-500">
                Automatically confirm online bookings
              </p>
            </div>
            <Switch checked={autoConfirm} onCheckedChange={setAutoConfirm} />
          </div>
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-rough-900">Waitlist</p>
              <p className="text-xs text-rough-500">
                Enable waitlist when fully booked
              </p>
            </div>
            <Switch checked={waitlist} onCheckedChange={setWaitlist} />
          </div>
        </div>
      );
    };
    return <SettingsPanel />;
  },
};
