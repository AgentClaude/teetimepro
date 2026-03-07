import type { Meta, StoryObj } from '@storybook/react';
import { MemoryRouter } from 'react-router-dom';
import { CustomerBookingsSection } from './CustomerBookingsSection';

const meta: Meta<typeof CustomerBookingsSection> = {
  title: 'Customers/CustomerBookingsSection',
  component: CustomerBookingsSection,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <MemoryRouter>
        <Story />
      </MemoryRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof CustomerBookingsSection>;

const sampleBookings = [
  {
    id: '1',
    confirmationCode: 'ABC12345',
    status: 'confirmed',
    playersCount: 4,
    totalCents: 28000,
    createdAt: '2026-03-07T10:00:00Z',
    teeTime: {
      id: 't1',
      startsAt: '2026-03-10T14:00:00Z',
      formattedTime: '2:00 PM',
      teeSheet: {
        date: '2026-03-10',
        course: { id: 'c1', name: 'Pinehurst No. 2' },
      },
    },
  },
  {
    id: '2',
    confirmationCode: 'XYZ98765',
    status: 'checked_in',
    playersCount: 2,
    totalCents: 14000,
    createdAt: '2026-03-06T08:00:00Z',
    teeTime: {
      id: 't2',
      startsAt: '2026-03-07T08:30:00Z',
      formattedTime: '8:30 AM',
      teeSheet: {
        date: '2026-03-07',
        course: { id: 'c1', name: 'Pinehurst No. 2' },
      },
    },
  },
  {
    id: '3',
    confirmationCode: 'CNC55555',
    status: 'cancelled',
    playersCount: 3,
    totalCents: 21000,
    createdAt: '2026-03-01T12:00:00Z',
    teeTime: {
      id: 't3',
      startsAt: '2026-03-05T10:00:00Z',
      formattedTime: '10:00 AM',
      teeSheet: {
        date: '2026-03-05',
        course: { id: 'c2', name: 'Augusta National' },
      },
    },
  },
];

export const Default: Story = {
  args: {
    bookings: sampleBookings,
  },
};

export const Empty: Story = {
  args: {
    bookings: [],
    emptyMessage: 'No upcoming bookings scheduled.',
  },
};

export const SingleBooking: Story = {
  args: {
    bookings: [sampleBookings[0]],
  },
};
