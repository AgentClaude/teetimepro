import type { Meta, StoryObj } from '@storybook/react';
import { BookingForm } from '../components/booking/BookingForm';

const meta: Meta<typeof BookingForm> = {
  title: 'Booking/BookingForm',
  component: BookingForm,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="mx-auto max-w-md rounded-lg bg-white p-6 shadow">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof BookingForm>;

export const Default: Story = {
  args: {
    teeTime: {
      id: '1',
      startsAt: '2026-03-06T07:00:00Z',
      availableSpots: 4,
      priceCents: 5500,
      courseName: 'Mountain View Golf Club',
    },
    onSubmit: (data) => console.log('Submit:', data),
    onCancel: () => console.log('Cancel'),
  },
};

export const LimitedAvailability: Story = {
  args: {
    teeTime: {
      id: '2',
      startsAt: '2026-03-06T09:30:00Z',
      availableSpots: 1,
      priceCents: 7500,
      courseName: 'Eagle Ridge Country Club',
    },
    onSubmit: (data) => console.log('Submit:', data),
    onCancel: () => console.log('Cancel'),
  },
};

export const Loading: Story = {
  args: {
    teeTime: {
      id: '3',
      startsAt: '2026-03-06T14:00:00Z',
      availableSpots: 4,
      priceCents: 3500,
      courseName: 'Sunset Links',
    },
    onSubmit: (data) => console.log('Submit:', data),
    onCancel: () => console.log('Cancel'),
    loading: true,
  },
};
