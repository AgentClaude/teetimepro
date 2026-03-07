import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { DashboardPage } from '../pages/DashboardPage';
import { GET_DASHBOARD_STATS, GET_COURSES } from '../graphql/queries';

const meta: Meta<typeof DashboardPage> = {
  title: 'Pages/DashboardPage',
  component: DashboardPage,
  tags: ['autodocs'],
  decorators: [
    (Story, { parameters }) => (
      <MockedProvider mocks={parameters.apolloMocks} addTypename={false}>
        <div className="min-h-screen bg-gray-50 p-6">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof DashboardPage>;

const mockCourses = [
  {
    id: '1',
    name: 'Pebble Beach Golf Links',
  },
  {
    id: '2', 
    name: 'Augusta National Golf Club',
  },
];

const mockDashboardStats = {
  todaysBookings: 12,
  todaysRevenueCents: 156750,
  activeMembers: 89,
  utilizationPercentage: 73.5,
  upcomingBookings: [
    {
      id: '1',
      confirmationCode: 'ABC123',
      userName: 'John Smith',
      courseName: 'Pebble Beach Golf Links',
      teeTime: '2024-03-07T10:30:00Z',
      playersCount: 4,
      totalCents: 12500,
    },
    {
      id: '2',
      confirmationCode: 'DEF456',
      userName: 'Sarah Johnson',
      courseName: 'Augusta National Golf Club',
      teeTime: '2024-03-07T11:00:00Z',
      playersCount: 2,
      totalCents: 7500,
    },
    {
      id: '3',
      confirmationCode: 'GHI789',
      userName: 'Mike Wilson',
      courseName: 'Pebble Beach Golf Links',
      teeTime: '2024-03-07T14:15:00Z',
      playersCount: 3,
      totalCents: 9000,
    },
  ],
  weeklyRevenue: [
    { date: '2024-03-01', revenueCents: 85000 },
    { date: '2024-03-02', revenueCents: 92500 },
    { date: '2024-03-03', revenueCents: 78000 },
    { date: '2024-03-04', revenueCents: 145000 },
    { date: '2024-03-05', revenueCents: 132500 },
    { date: '2024-03-06', revenueCents: 167000 },
    { date: '2024-03-07', revenueCents: 156750 },
  ],
};

const mockEmptyStats = {
  todaysBookings: 0,
  todaysRevenueCents: 0,
  activeMembers: 0,
  utilizationPercentage: 0,
  upcomingBookings: [],
  weeklyRevenue: [
    { date: '2024-03-01', revenueCents: 0 },
    { date: '2024-03-02', revenueCents: 0 },
    { date: '2024-03-03', revenueCents: 0 },
    { date: '2024-03-04', revenueCents: 0 },
    { date: '2024-03-05', revenueCents: 0 },
    { date: '2024-03-06', revenueCents: 0 },
    { date: '2024-03-07', revenueCents: 0 },
  ],
};

export const WithData: Story = {
  parameters: {
    apolloMocks: [
      {
        request: {
          query: GET_COURSES,
        },
        result: {
          data: {
            courses: mockCourses,
          },
        },
      },
      {
        request: {
          query: GET_DASHBOARD_STATS,
        },
        result: {
          data: {
            dashboardStats: mockDashboardStats,
          },
        },
      },
    ],
  },
};

export const EmptyState: Story = {
  parameters: {
    apolloMocks: [
      {
        request: {
          query: GET_COURSES,
        },
        result: {
          data: {
            courses: [],
          },
        },
      },
      {
        request: {
          query: GET_DASHBOARD_STATS,
        },
        result: {
          data: {
            dashboardStats: mockEmptyStats,
          },
        },
      },
    ],
  },
};

export const Loading: Story = {
  parameters: {
    apolloMocks: [
      {
        request: {
          query: GET_COURSES,
        },
        delay: 2000,
        result: {
          data: {
            courses: mockCourses,
          },
        },
      },
      {
        request: {
          query: GET_DASHBOARD_STATS,
        },
        delay: 2000,
        result: {
          data: {
            dashboardStats: mockDashboardStats,
          },
        },
      },
    ],
  },
};

export const Error: Story = {
  parameters: {
    apolloMocks: [
      {
        request: {
          query: GET_COURSES,
        },
        result: {
          data: {
            courses: [],
          },
        },
      },
      {
        request: {
          query: GET_DASHBOARD_STATS,
        },
        error: new Error('Failed to load dashboard data'),
      },
    ],
  },
};

export const SingleCourse: Story = {
  parameters: {
    apolloMocks: [
      {
        request: {
          query: GET_COURSES,
        },
        result: {
          data: {
            courses: [mockCourses[0]],
          },
        },
      },
      {
        request: {
          query: GET_DASHBOARD_STATS,
        },
        result: {
          data: {
            dashboardStats: mockDashboardStats,
          },
        },
      },
    ],
  },
};
