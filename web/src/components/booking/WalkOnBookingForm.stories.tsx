import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { WalkOnBookingForm, CREATE_WALK_ON_BOOKING } from './WalkOnBookingForm';

const meta: Meta<typeof WalkOnBookingForm> = {
  title: 'Booking/WalkOnBookingForm',
  component: WalkOnBookingForm,
  decorators: [
    (Story) => (
      <div className="max-w-md mx-auto p-4">
        <Story />
      </div>
    ),
  ],
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof WalkOnBookingForm>;

const successMock = {
  request: {
    query: CREATE_WALK_ON_BOOKING,
    variables: {
      teeTimeId: 'tt-1',
      playersCount: 2,
      guestName: 'John Walk-In',
      guestEmail: 'john@example.com',
      guestPhone: '+15551234567',
      walkOnNotes: 'Needs rental clubs',
    },
  },
  result: {
    data: {
      createWalkOnBooking: {
        booking: {
          id: 'bk-123',
          confirmationCode: 'WO-ABC123',
          bookingType: 'walk_on',
          guestName: 'John Walk-In',
          guestEmail: 'john@example.com',
          guestPhone: '+15551234567',
          walkOnNotes: 'Needs rental clubs',
          isWalkOn: true,
          playersCount: 2,
          status: 'confirmed',
          totalCents: 9000,
          teeTime: {
            id: 'tt-1',
            startsAt: new Date(Date.now() + 3600000).toISOString(),
          },
        },
        teeTime: {
          id: 'tt-1',
          startsAt: new Date(Date.now() + 3600000).toISOString(),
          availableSpots: 2,
        },
        errors: [],
      },
    },
  },
};

/**
 * Walk-on form with a pre-selected tee time
 */
export const WithTeeTime: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
  args: {
    teeTimeId: 'tt-1',
    teeTimeInfo: {
      startsAt: new Date(Date.now() + 3600000).toISOString(),
      courseName: 'Pine Valley Golf Club',
      availableSpots: 3,
    },
    onBookingComplete: (booking) => console.log('Booking created:', booking),
    onCancel: () => console.log('Cancelled'),
  },
};

/**
 * Auto-assign mode: staff picks a course, system finds next available slot
 */
export const AutoAssign: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
  args: {
    courses: [
      { id: 'c-1', name: 'Pine Valley Golf Club' },
      { id: 'c-2', name: 'Oak Ridge Country Club' },
      { id: 'c-3', name: 'Sunset Links' },
    ],
    onBookingComplete: (booking) => console.log('Booking created:', booking),
    onCancel: () => console.log('Cancelled'),
  },
};

/**
 * Minimal form without cancel button
 */
export const Minimal: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
  args: {
    teeTimeId: 'tt-1',
    teeTimeInfo: {
      startsAt: new Date(Date.now() + 7200000).toISOString(),
      courseName: 'Augusta National',
      availableSpots: 1,
    },
  },
};
