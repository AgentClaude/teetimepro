import type { Meta, StoryObj } from '@storybook/react';
import { Button } from '../components/ui/Button';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'danger'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { children: 'Book Tee Time', variant: 'primary' },
};

export const Secondary: Story = {
  args: { children: 'View Details', variant: 'secondary' },
};

export const Ghost: Story = {
  args: { children: 'Cancel', variant: 'ghost' },
};

export const Danger: Story = {
  args: { children: 'Cancel Booking', variant: 'danger' },
};

export const Small: Story = {
  args: { children: 'Edit', variant: 'primary', size: 'sm' },
};

export const Large: Story = {
  args: { children: 'Confirm Booking', variant: 'primary', size: 'lg' },
};

export const Disabled: Story = {
  args: { children: 'Processing...', variant: 'primary', disabled: true },
};
