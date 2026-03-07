import { useState } from "react";
import type { Meta, StoryObj } from "@storybook/react";
import { Modal } from "./Modal";
import { Button } from "./Button";
import { Input } from "./Input";

const meta: Meta<typeof Modal> = {
  title: "UI/Modal",
  component: Modal,
  tags: ["autodocs"],
  argTypes: {
    size: {
      control: "select",
      options: ["sm", "md", "lg", "xl"],
    },
    isOpen: { control: "boolean" },
  },
};

export default meta;
type Story = StoryObj<typeof Modal>;

export const Default: Story = {
  args: {
    isOpen: true,
    title: "Confirm Booking",
    children: (
      <div>
        <p className="text-sm text-rough-600">
          Are you sure you want to book the 7:30 AM tee time for 4 players?
        </p>
        <div className="flex justify-end gap-3 mt-6">
          <Button variant="secondary">Cancel</Button>
          <Button variant="primary">Confirm</Button>
        </div>
      </div>
    ),
  },
};

export const WithForm: Story = {
  args: {
    isOpen: true,
    title: "Add Player",
    children: (
      <div className="space-y-4">
        <Input label="Full Name" id="name" placeholder="Enter player name" />
        <Input
          label="Email"
          id="email"
          type="email"
          placeholder="player@example.com"
        />
        <Input
          label="Handicap"
          id="handicap"
          type="number"
          placeholder="0-54"
        />
        <div className="flex justify-end gap-3 mt-6">
          <Button variant="secondary">Cancel</Button>
          <Button variant="primary">Add Player</Button>
        </div>
      </div>
    ),
  },
};

export const SmallModal: Story = {
  args: {
    isOpen: true,
    title: "Delete Booking",
    size: "sm",
    children: (
      <div>
        <p className="text-sm text-rough-600">
          This action cannot be undone. The tee time will be released.
        </p>
        <div className="flex justify-end gap-3 mt-6">
          <Button variant="secondary">Keep</Button>
          <Button variant="danger">Delete</Button>
        </div>
      </div>
    ),
  },
};

export const LargeModal: Story = {
  args: {
    isOpen: true,
    title: "Booking Details",
    size: "lg",
    children: (
      <div className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-rough-500">Date</p>
            <p className="text-sm font-medium text-rough-900">March 7, 2026</p>
          </div>
          <div>
            <p className="text-xs text-rough-500">Time</p>
            <p className="text-sm font-medium text-rough-900">7:30 AM</p>
          </div>
          <div>
            <p className="text-xs text-rough-500">Players</p>
            <p className="text-sm font-medium text-rough-900">4</p>
          </div>
          <div>
            <p className="text-xs text-rough-500">Rate</p>
            <p className="text-sm font-medium text-rough-900">$65.00/player</p>
          </div>
        </div>
        <div className="border-t border-rough-200 pt-4">
          <p className="text-xs text-rough-500">Total</p>
          <p className="text-lg font-bold text-rough-900">$260.00</p>
        </div>
      </div>
    ),
  },
};

export const Interactive: Story = {
  render: () => {
    const InteractiveModal = () => {
      const [isOpen, setIsOpen] = useState(false);
      return (
        <>
          <Button onClick={() => setIsOpen(true)}>Open Modal</Button>
          <Modal
            isOpen={isOpen}
            onClose={() => setIsOpen(false)}
            title="Interactive Example"
          >
            <p className="text-sm text-rough-600">
              Click outside or press Escape to close.
            </p>
            <div className="flex justify-end mt-6">
              <Button onClick={() => setIsOpen(false)}>Close</Button>
            </div>
          </Modal>
        </>
      );
    };
    return <InteractiveModal />;
  },
};
