import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { DashboardPage } from './DashboardPage';
import { GET_DASHBOARD_STATS, GET_COURSES, GET_UTILIZATION_HEAT_MAP } from '../graphql/queries';
import type { UtilizationHeatMapCell, UtilizationHeatMapSummary } from '../types';

// Mock data generators
function generateMockRevenueData(days: number) {
  const data = [];
  const today = new Date();
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
    const dateString = date.toISOString().split('T')[0];
    const baseRevenue = 250000;
    const variation = Math.random() * 150000;
    const dayOfWeek = date.getDay();
    const weekendMultiplier = dayOfWeek === 0 || dayOfWeek === 6 ? 1.4 : 1.0;
    
    data.push({
      date: dateString,
      revenueCents: Math.round((baseRevenue + variation) * weekendMultiplier),
    });
  }
  
  return data;
}

function generateMockUpcomingBookings() {
  return [
    {
      id: '1',
      confirmationCode: 'ABC123',
      userName: 'John Smith',
      courseName: 'Pine Valley Golf Course',
      teeTime: '2024-03-16T09:00:00Z',
      playersCount: 4,
      totalCents: 32000,
    },
    {
      id: '2',
      confirmationCode: 'DEF456',
      userName: 'Sarah Johnson',
      courseName: 'Oak Hill Country Club',
      teeTime: '2024-03-16T10:30:00Z',
      playersCount: 2,
      totalCents: 18000,
    },
    {
      id: '3',
      confirmationCode: 'GHI789',
      userName: 'Mike Wilson',
      courseName: 'Pine Valley Golf Course',
      teeTime: '2024-03-16T14:00:00Z',
      playersCount: 3,
      totalCents: 25500,
    },
  ];
}

function generateMockHeatMapCells(): UtilizationHeatMapCell[] {
  const cells: UtilizationHeatMapCell[] = [];
  const today = new Date();
  
  for (let dayOffset = 6; dayOffset >= 0; dayOffset--) {
    const date = new Date(today.getTime() - dayOffset * 24 * 60 * 60 * 1000);
    const dateString = date.toISOString().split('T')[0];
    
    for (let hour = 6; hour <= 18; hour++) {
      const isWeekend = date.getDay() === 0 || date.getDay() === 6;
      const isPeakTime = hour >= 7 && hour <= 10;
      
      let baseUtilization = 30;
      if (isWeekend) baseUtilization += 25;
      if (isPeakTime) baseUtilization += 30;
      
      const variation = Math.random() * 40 - 20;
      const utilization = Math.max(0, Math.min(100, baseUtilization + variation));
      
      cells.push({
        date: dateString,
        hour,
        utilizationPercentage: utilization,
        bookedPlayers: Math.round((utilization / 100) * 16),
        totalCapacity: 16,
        slotCount: 4,
      });
    }
  }
  
  return cells;
}

function generateMockHeatMapSummary(): UtilizationHeatMapSummary {
  return {
    overallUtilization: 65.4,
    totalBookedPlayers: 1247,
    totalCapacity: 1904,
    peakHour: 9,
    peakHourUtilization: 87.2,
    peakDayOfWeek: 'Saturday',
    peakDayUtilization: 78.5,
    dateRangeDays: 7,
  };
}

// Mock GraphQL responses
const mockCourses = [
  { id: '1', name: 'Pine Valley Golf Course' },
  { id: '2', name: 'Oak Hill Country Club' },
  { id: '3', name: 'Riverside Golf Resort' },
];

const successMocks = [
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
      variables: {},
    },
    result: {
      data: {
        dashboardStats: {
          todaysBookings: 12,
          todaysRevenueCents: 875000,
          activeMembers: 342,
          utilizationPercentage: 67.8,
          upcomingBookings: generateMockUpcomingBookings(),
          weeklyRevenue: generateMockRevenueData(7),
        },
      },
    },
  },
  {
    request: {
      query: GET_UTILIZATION_HEAT_MAP,
    },
    result: {
      data: {
        utilizationHeatMap: {
          cells: generateMockHeatMapCells(),
          summary: generateMockHeatMapSummary(),
        },
      },
    },
    variableMatcher: () => true,
  },
];

const loadingMocks = [
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
      variables: {},
    },
    delay: 2000,
    result: {
      data: {
        dashboardStats: {
          todaysBookings: 12,
          todaysRevenueCents: 875000,
          activeMembers: 342,
          utilizationPercentage: 67.8,
          upcomingBookings: generateMockUpcomingBookings(),
          weeklyRevenue: generateMockRevenueData(7),
        },
      },
    },
  },
  {
    request: {
      query: GET_UTILIZATION_HEAT_MAP,
    },
    delay: 2000,
    result: {
      data: {
        utilizationHeatMap: {
          cells: generateMockHeatMapCells(),
          summary: generateMockHeatMapSummary(),
        },
      },
    },
    variableMatcher: () => true,
  },
];

const emptyMocks = [
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
      variables: {},
    },
    result: {
      data: {
        dashboardStats: {
          todaysBookings: 0,
          todaysRevenueCents: 0,
          activeMembers: 0,
          utilizationPercentage: 0,
          upcomingBookings: [],
          weeklyRevenue: [],
        },
      },
    },
  },
  {
    request: {
      query: GET_UTILIZATION_HEAT_MAP,
    },
    result: {
      data: {
        utilizationHeatMap: {
          cells: [],
          summary: {
            overallUtilization: 0,
            totalBookedPlayers: 0,
            totalCapacity: 0,
            peakHour: null,
            peakHourUtilization: 0,
            peakDayOfWeek: null,
            peakDayUtilization: 0,
            dateRangeDays: 7,
          },
        },
      },
    },
    variableMatcher: () => true,
  },
];

const errorMocks = [
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
      variables: {},
    },
    error: new globalThis.Error('Failed to load dashboard data'),
  },
  {
    request: {
      query: GET_UTILIZATION_HEAT_MAP,
    },
    error: new globalThis.Error('Failed to load utilization data'),
    variableMatcher: () => true,
  },
];

const meta = {
  title: 'Pages/DashboardPage',
  component: DashboardPage,
  parameters: {
    layout: 'padded',
  },
  tags: ['autodocs'],
  decorators: [
    (Story, { parameters }) => (
      <MockedProvider mocks={parameters.mocks} addTypename={false}>
        <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
          <div className="max-w-7xl mx-auto px-4 py-6">
            <Story />
          </div>
        </div>
      </MockedProvider>
    ),
  ],
} satisfies Meta<typeof DashboardPage>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Populated: Story = {
  parameters: {
    mocks: successMocks,
  },
};

export const Loading: Story = {
  parameters: {
    mocks: loadingMocks,
  },
};

export const Empty: Story = {
  parameters: {
    mocks: emptyMocks,
  },
};

export const Error: Story = {
  parameters: {
    mocks: errorMocks,
  },
};