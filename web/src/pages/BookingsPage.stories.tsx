import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { BrowserRouter } from 'react-router-dom';
import { BookingsPage } from './BookingsPage';
import { GET_BOOKINGS, GET_COURSES } from '../graphql/queries';
import { CANCEL_BOOKING } from '../graphql/mutations';
import { CourseProvider } from '../contexts/CourseContext';

const meta: Meta<typeof BookingsPage> = {
  title: 'Pages/BookingsPage',
  component: BookingsPage,
  parameters: {
    layout: 'fullscreen',
  },
  decorators: [
    (Story) => (
      <BrowserRouter>
        <MockedProvider>
          <CourseProvider>
            <div className="p-6 min-h-screen bg-gray-50">
              <Story />
            </div>
          </CourseProvider>
        </MockedProvider>
      </BrowserRouter>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

// Mock booking data
const mockBookings = [
  {
    id: '1',
    confirmationCode: 'ABC123',
    status: 'CONFIRMED',
    playersCount: 4,
    totalCents: 15000,
    cancellable: true,
    createdAt: '2024-03-08T10:00:00Z',
    teeTime: {
      id: 't1',
      startsAt: '2024-03-08T14:00:00Z',
      formattedTime: '2:00 PM',
      course: {
        name: 'Pebble Beach Golf Course',
      },
    },
    user: {
      id: 'u1',
      fullName: 'John Smith',
      email: 'john.smith@email.com',
    },
    bookingPlayers: [
      { id: 'bp1', name: 'John Smith' },
      { id: 'bp2', name: 'Jane Doe' },
      { id: 'bp3', name: 'Bob Wilson' },
      { id: 'bp4', name: 'Alice Brown' },
    ],
  },
  {
    id: '2',
    confirmationCode: 'DEF456',
    status: 'CHECKED_IN',
    playersCount: 2,
    totalCents: 8000,
    cancellable: false,
    createdAt: '2024-03-08T11:30:00Z',
    teeTime: {
      id: 't2',
      startsAt: '2024-03-08T15:30:00Z',
      formattedTime: '3:30 PM',
      course: {
        name: 'Pebble Beach Golf Course',
      },
    },
    user: {
      id: 'u2',
      fullName: 'Sarah Johnson',
      email: 'sarah.j@email.com',
    },
    bookingPlayers: [
      { id: 'bp5', name: 'Sarah Johnson' },
      { id: 'bp6', name: 'Mike Davis' },
    ],
  },
  {
    id: '3',
    confirmationCode: 'GHI789',
    status: 'COMPLETED',
    playersCount: 3,
    totalCents: 12000,
    cancellable: false,
    createdAt: '2024-03-07T09:15:00Z',
    teeTime: {
      id: 't3',
      startsAt: '2024-03-07T13:00:00Z',
      formattedTime: '1:00 PM',
      course: {
        name: 'Pebble Beach Golf Course',
      },
    },
    user: {
      id: 'u3',
      fullName: 'Robert Taylor',
      email: 'robert.t@email.com',
    },
    bookingPlayers: [
      { id: 'bp7', name: 'Robert Taylor' },
      { id: 'bp8', name: 'Lisa Chen' },
      { id: 'bp9', name: 'Tom Anderson' },
    ],
  },
  {
    id: '4',
    confirmationCode: 'JKL012',
    status: 'CANCELLED',
    playersCount: 4,
    totalCents: 16000,
    cancellable: false,
    createdAt: '2024-03-06T14:20:00Z',
    teeTime: {
      id: 't4',
      startsAt: '2024-03-08T16:00:00Z',
      formattedTime: '4:00 PM',
      course: {
        name: 'Pebble Beach Golf Course',
      },
    },
    user: {
      id: 'u4',
      fullName: 'Emily Rodriguez',
      email: 'emily.r@email.com',
    },
    bookingPlayers: [
      { id: 'bp10', name: 'Emily Rodriguez' },
      { id: 'bp11', name: 'Mark Thompson' },
      { id: 'bp12', name: 'Jennifer Lee' },
      { id: 'bp13', name: 'David Kim' },
    ],
  },
];

// Mock courses data for CourseProvider
const mockCoursesData = {
  courses: [
    {
      id: 'course-1',
      name: 'Pebble Beach Golf Course',
      holes: 18,
      intervalMinutes: 10,
      maxPlayersPerSlot: 4,
      firstTeeTime: '06:00',
      lastTeeTime: '18:00',
      weekdayRateCents: 15000,
      weekendRateCents: 20000,
    },
  ],
};

const getCoursesMock = {
  request: {
    query: GET_COURSES,
  },
  result: {
    data: mockCoursesData,
  },
};

// Successful query mock
const successMock = {
  request: {
    query: GET_BOOKINGS,
    variables: {
      courseId: 'course-1',
    },
  },
  result: {
    data: {
      bookings: mockBookings,
    },
  },
};

// Empty results mock
const emptyMock = {
  request: {
    query: GET_BOOKINGS,
    variables: {
      courseId: 'course-1',
    },
  },
  result: {
    data: {
      bookings: [],
    },
  },
};

// Loading mock
const loadingMock = {
  request: {
    query: GET_BOOKINGS,
    variables: {
      courseId: 'course-1',
    },
  },
  result: {
    data: {
      bookings: mockBookings,
    },
  },
  delay: 2000, // Simulate slow network
};

// Cancel booking mutation mock
const cancelBookingMock = {
  request: {
    query: CANCEL_BOOKING,
    variables: {
      bookingId: '1',
      reason: 'Customer requested cancellation',
      refund: true,
    },
  },
  result: {
    data: {
      cancelBooking: {
        booking: {
          id: '1',
          status: 'CANCELLED',
          cancelledAt: new Date().toISOString(),
          cancellationReason: 'Customer requested cancellation',
        },
        errors: null,
      },
    },
  },
};

// Mock CourseProvider with selected course
const MockCourseProvider = ({ children }: { children: React.ReactNode }) => {
  // Override localStorage behavior
  (window as unknown as { localStorage: Storage }).localStorage = {
    getItem: (key: string) => {
      if (key === 'selectedCourseId') return 'course-1';
      if (key === 'auth_token') return 'mock-token';
      return null;
    },
    setItem: () => {},
    removeItem: () => {},
    clear: () => {},
    key: () => null,
    length: 0,
  };

  return (
    <CourseProvider>
      {children}
    </CourseProvider>
  );
};

export const DefaultView: Story = {
  decorators: [
    (Story) => (
      <BrowserRouter>
        <MockedProvider mocks={[getCoursesMock, successMock, cancelBookingMock]} addTypename={false}>
          <MockCourseProvider>
            <div className="p-6 min-h-screen bg-gray-50">
              <Story />
            </div>
          </MockCourseProvider>
        </MockedProvider>
      </BrowserRouter>
    ),
  ],
};

export const EmptyState: Story = {
  decorators: [
    (Story) => (
      <BrowserRouter>
        <MockedProvider mocks={[getCoursesMock, emptyMock]} addTypename={false}>
          <MockCourseProvider>
            <div className="p-6 min-h-screen bg-gray-50">
              <Story />
            </div>
          </MockCourseProvider>
        </MockedProvider>
      </BrowserRouter>
    ),
  ],
};

export const LoadingState: Story = {
  decorators: [
    (Story) => (
      <BrowserRouter>
        <MockedProvider mocks={[getCoursesMock, loadingMock]} addTypename={false}>
          <MockCourseProvider>
            <div className="p-6 min-h-screen bg-gray-50">
              <Story />
            </div>
          </MockCourseProvider>
        </MockedProvider>
      </BrowserRouter>
    ),
  ],
};

// Mock CourseProvider with no selected course
const MockCourseProviderNoSelection = ({ children }: { children: React.ReactNode }) => {
  // Mock localStorage for no selection
  (window as unknown as { localStorage: Storage }).localStorage = {
    getItem: (key: string) => {
      if (key === 'selectedCourseId') return '';
      if (key === 'auth_token') return 'mock-token';
      return null;
    },
    setItem: () => {},
    removeItem: () => {},
    clear: () => {},
    key: () => null,
    length: 0,
  };

  return (
    <CourseProvider>
      {children}
    </CourseProvider>
  );
};

export const NoCourseSelected: Story = {
  decorators: [
    (Story) => (
      <BrowserRouter>
        <MockedProvider mocks={[getCoursesMock]} addTypename={false}>
          <MockCourseProviderNoSelection>
            <div className="p-6 min-h-screen bg-gray-50">
              <Story />
            </div>
          </MockCourseProviderNoSelection>
        </MockedProvider>
      </BrowserRouter>
    ),
  ],
};