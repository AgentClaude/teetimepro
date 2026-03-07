import type { Meta, StoryObj } from '@storybook/react';
import { VoiceBookingStatus } from './VoiceBookingStatus';
import type { Booking, User, TeeTime } from '../../types';

const meta: Meta<typeof VoiceBookingStatus> = {
  title: 'Voice/VoiceBookingStatus',
  component: VoiceBookingStatus,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Displays voice booking status with pending confirmations and countdown timers.',
      },
    },
  },
};

export default meta;
type Story = StoryObj<typeof VoiceBookingStatus>;

// Mock data
// const mockTeeSheet: TeeSheet = {
//   id: 'sheet-1',
//   date: '2024-03-08',
//   courseId: 'course-1',
//   totalSlots: 48,
//   availableSlots: 32,
//   utilizationPercentage: 66.7,
//   teeTimes: [],
//   course: mockCourse,
// };

const mockTeeTime: TeeTime = {
  id: 'tee-time-1',
  startsAt: '2024-03-08T09:00:00Z',
  formattedTime: '9:00 AM',
  status: 'partially_booked',
  maxPlayers: 4,
  bookedPlayers: 2,
  availableSpots: 2,
  priceCents: 7500,
  notes: null,
  bookings: [],
};

const mockUser: User = {
  id: 'user-1',
  email: '15551234567@voice-booking.local',
  firstName: 'John',
  lastName: 'Doe',
  fullName: 'John Doe',
  role: 'golfer',
  organizationId: 'org-1',
  calendarConnections: [],
};

const mockPendingBooking: Booking = {
  id: 'booking-1',
  confirmationCode: 'VB7K92XF',
  status: 'pending_voice_confirmation',
  playersCount: 2,
  totalCents: 15000,
  cancellable: false,
  cancelledAt: null,
  cancellationReason: null,
  createdAt: new Date(Date.now() - 2 * 60 * 1000).toISOString(), // 2 minutes ago
  teeTime: mockTeeTime,
  user: mockUser,
  bookingPlayers: [],
};

const mockConfirmedBooking: Booking = {
  id: 'booking-2',
  confirmationCode: 'VB8H54NP',
  status: 'confirmed',
  playersCount: 3,
  totalCents: 22500,
  cancellable: true,
  cancelledAt: null,
  cancellationReason: null,
  createdAt: new Date(Date.now() - 10 * 60 * 1000).toISOString(), // 10 minutes ago
  teeTime: {
    ...mockTeeTime,
    id: 'tee-time-2',
    startsAt: '2024-03-08T14:30:00Z',
    formattedTime: '2:30 PM',
  },
  user: {
    ...mockUser,
    id: 'user-2',
    firstName: 'Jane',
    lastName: 'Smith',
    fullName: 'Jane Smith',
  },
  bookingPlayers: [],
};

const mockExpiredBooking: Booking = {
  id: 'booking-3',
  confirmationCode: 'VB2M77QW',
  status: 'pending_voice_confirmation',
  playersCount: 1,
  totalCents: 7500,
  cancellable: false,
  cancelledAt: null,
  cancellationReason: null,
  createdAt: new Date(Date.now() - 6 * 60 * 1000).toISOString(), // 6 minutes ago (expired)
  teeTime: {
    ...mockTeeTime,
    id: 'tee-time-3',
    startsAt: '2024-03-08T11:00:00Z',
    formattedTime: '11:00 AM',
  },
  user: {
    ...mockUser,
    id: 'user-3',
    firstName: 'Bob',
    lastName: 'Wilson',
    fullName: 'Bob Wilson',
  },
  bookingPlayers: [],
};

const defaultHandlers = {
  onRefresh: () => console.log('Refresh clicked'),
};

export const Empty: Story = {
  args: {
    bookings: [],
    ...defaultHandlers,
  },
};

export const PendingOnly: Story = {
  args: {
    bookings: [mockPendingBooking],
    ...defaultHandlers,
  },
};

export const ConfirmedOnly: Story = {
  args: {
    bookings: [mockConfirmedBooking],
    ...defaultHandlers,
  },
};

export const Mixed: Story = {
  args: {
    bookings: [mockPendingBooking, mockConfirmedBooking],
    ...defaultHandlers,
  },
};

export const MultiplePending: Story = {
  args: {
    bookings: [
      mockPendingBooking,
      {
        ...mockPendingBooking,
        id: 'booking-4',
        confirmationCode: 'VB9X33ZK',
        createdAt: new Date(Date.now() - 4 * 60 * 1000).toISOString(), // 4 minutes ago
        playersCount: 4,
        totalCents: 30000,
        teeTime: {
          ...mockTeeTime,
          id: 'tee-time-4',
          startsAt: '2024-03-08T16:00:00Z',
          formattedTime: '4:00 PM',
        },
      },
    ],
    ...defaultHandlers,
  },
};

export const ExpiredBooking: Story = {
  args: {
    bookings: [mockExpiredBooking],
    ...defaultHandlers,
  },
};

export const PendingAndExpired: Story = {
  args: {
    bookings: [mockPendingBooking, mockExpiredBooking],
    ...defaultHandlers,
  },
};

export const FullExample: Story = {
  args: {
    bookings: [
      mockPendingBooking,
      mockExpiredBooking,
      mockConfirmedBooking,
      {
        ...mockConfirmedBooking,
        id: 'booking-5',
        confirmationCode: 'VB5R88LP',
        teeTime: {
          ...mockTeeTime,
          id: 'tee-time-5',
          startsAt: '2024-03-08T10:30:00Z',
          formattedTime: '10:30 AM',
        },
        user: {
          ...mockUser,
          id: 'user-4',
          firstName: 'Sarah',
          lastName: 'Johnson',
          fullName: 'Sarah Johnson',
        },
        playersCount: 1,
        totalCents: 7500,
      },
    ],
    ...defaultHandlers,
  },
};

export const LongConfirmationCode: Story = {
  args: {
    bookings: [
      {
        ...mockPendingBooking,
        confirmationCode: 'VOICE123BOOKING456',
      },
    ],
    ...defaultHandlers,
  },
};

export const HighValue: Story = {
  args: {
    bookings: [
      {
        ...mockPendingBooking,
        playersCount: 4,
        totalCents: 40000, // $400
      },
    ],
    ...defaultHandlers,
  },
};

export const NearExpiry: Story = {
  args: {
    bookings: [
      {
        ...mockPendingBooking,
        createdAt: new Date(Date.now() - 4.5 * 60 * 1000).toISOString(), // 4.5 minutes ago (30 seconds left)
      },
    ],
    ...defaultHandlers,
  },
  parameters: {
    docs: {
      description: {
        story: 'Booking with less than 30 seconds remaining before auto-cancellation.',
      },
    },
  },
};

export const WithoutRefresh: Story = {
  args: {
    bookings: [mockPendingBooking, mockConfirmedBooking],
    // No onRefresh handler
  },
};

export const CustomClassName: Story = {
  args: {
    bookings: [mockPendingBooking],
    className: 'max-w-md mx-auto border rounded-lg p-4',
    ...defaultHandlers,
  },
};