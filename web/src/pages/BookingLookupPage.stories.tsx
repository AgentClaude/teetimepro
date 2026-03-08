import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider, MockedResponse } from '@apollo/client/testing';
import { BrowserRouter } from 'react-router-dom';
import { BookingLookupPage } from './BookingLookupPage';
import { LOOKUP_PUBLIC_BOOKING } from '../graphql/public';

const meta: Meta<typeof BookingLookupPage> = {
  title: 'Pages/BookingLookupPage',
  component: BookingLookupPage,
  parameters: {
    layout: 'fullscreen',
  },
  decorators: [
    (Story) => (
      <BrowserRouter>
        <Story />
      </BrowserRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

const mockBookingResult = {
  id: '1',
  confirmationCode: 'ABC12345',
  status: 'confirmed',
  playersCount: 4,
  totalCents: 16000,
  bookingType: 'online',
  cancelledAt: null,
  cancellationReason: null,
  createdAt: '2026-03-08T10:00:00Z',
  courseName: 'Pebble Beach Golf Links',
  teeTimeStartsAt: '2026-03-15T14:00:00Z',
  teeTimeFormatted: '2:00 PM',
  teeTimeDate: '2026-03-15',
  playerNames: ['John Smith', 'Jane Doe', 'Bob Wilson', 'Alice Brown'],
};

const successMock: MockedResponse = {
  request: {
    query: LOOKUP_PUBLIC_BOOKING,
    variables: {
      confirmationCode: 'ABC12345',
      email: 'john@example.com',
    },
  },
  result: {
    data: {
      publicBookingLookup: mockBookingResult,
    },
  },
};

const cancelledMock: MockedResponse = {
  request: {
    query: LOOKUP_PUBLIC_BOOKING,
    variables: {
      confirmationCode: 'DEF67890',
      email: 'jane@example.com',
    },
  },
  result: {
    data: {
      publicBookingLookup: {
        ...mockBookingResult,
        id: '2',
        confirmationCode: 'DEF67890',
        status: 'cancelled',
        cancelledAt: '2026-03-10T09:00:00Z',
        cancellationReason: 'Weather conditions',
      },
    },
  },
};

const notFoundMock: MockedResponse = {
  request: {
    query: LOOKUP_PUBLIC_BOOKING,
    variables: {
      confirmationCode: 'NOTFOUND',
      email: 'nobody@example.com',
    },
  },
  result: {
    data: {
      publicBookingLookup: null,
    },
  },
};

// Default: empty form
export const Default: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};

// With a found booking
export const BookingFound: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};

// Cancelled booking
export const CancelledBooking: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[cancelledMock]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};

// Booking not found
export const NotFound: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[notFoundMock]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};
