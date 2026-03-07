import type { Meta, StoryObj } from '@storybook/react';
import { AddItemDialog } from './AddItemDialog';

const meta: Meta<typeof AddItemDialog> = {
  title: 'FnB/AddItemDialog',
  component: AddItemDialog,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof AddItemDialog>;

const defaultHandlers = {
  onClose: () => console.log('Close dialog'),
  onSubmit: (data: {
    name: string;
    quantity: number;
    unitPriceCents: number;
    category: 'food' | 'beverage' | 'other';
    notes?: string;
  }) => console.log('Submit item:', data),
};

export const Default: Story = {
  args: {
    isOpen: true,
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    isOpen: true,
    loading: true,
    ...defaultHandlers,
  },
};

export const WithPrefilledData: Story = {
  args: {
    isOpen: true,
    ...defaultHandlers,
  },
};
