import type { Meta, StoryObj } from '@storybook/react';
import RecentActivityFeed from './RecentActivityFeed';

const meta: Meta<typeof RecentActivityFeed> = {
  title: 'Dashboard/RecentActivityFeed',
  component: RecentActivityFeed,
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

const sampleActivities = [
  {
    id: '1',
    activityType: 'no_show' as const,
    confirmationCode: 'ABC123XY',
    userName: 'John Smith',
    courseName: 'Pine Valley Golf Course',
    teeTime: '2024-03-16T14:30:00Z',
    playersCount: 4,
    occurredAt: new Date(Date.now() - 2 * 60 * 1000).toISOString(), // 2 minutes ago
  },
  {
    id: '2',
    activityType: 'checked_in' as const,
    confirmationCode: 'DEF456AB',
    userName: 'Sarah Johnson',
    courseName: 'Mountain View Golf Club',
    teeTime: '2024-03-16T13:15:00Z',
    playersCount: 2,
    occurredAt: new Date(Date.now() - 15 * 60 * 1000).toISOString(), // 15 minutes ago
  },
  {
    id: '3',
    activityType: 'cancelled' as const,
    confirmationCode: 'GHI789CD',
    userName: 'Mike Wilson',
    courseName: 'Oak Hill Country Club',
    teeTime: '2024-03-16T16:45:00Z',
    playersCount: 3,
    occurredAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(), // 45 minutes ago
  },
  {
    id: '4',
    activityType: 'booked' as const,
    confirmationCode: 'JKL012EF',
    userName: 'Emma Davis',
    courseName: 'Riverside Golf Resort',
    teeTime: '2024-03-16T11:00:00Z',
    playersCount: 1,
    occurredAt: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(), // 1 hour ago
  },
  {
    id: '5',
    activityType: 'completed' as const,
    confirmationCode: 'MNO345GH',
    userName: 'David Brown',
    courseName: 'Sunset Golf Links',
    teeTime: '2024-03-16T09:30:00Z',
    playersCount: 4,
    occurredAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
  },
];

export const Default: Story = {
  args: {
    activities: sampleActivities,
    loading: false,
  },
};

export const Loading: Story = {
  args: {
    activities: [],
    loading: true,
  },
};

export const Empty: Story = {
  args: {
    activities: [],
    loading: false,
  },
};

export const SingleActivity: Story = {
  args: {
    activities: [sampleActivities[0]],
    loading: false,
  },
};

export const BookedOnly: Story = {
  args: {
    activities: [
      {
        id: '1',
        activityType: 'booked' as const,
        confirmationCode: 'ABC123XY',
        userName: 'John Smith',
        courseName: 'Pine Valley Golf Course',
        teeTime: '2024-03-16T14:30:00Z',
        playersCount: 4,
        occurredAt: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
      },
      {
        id: '2',
        activityType: 'booked' as const,
        confirmationCode: 'DEF456AB',
        userName: 'Sarah Johnson',
        courseName: 'Mountain View Golf Club',
        teeTime: '2024-03-16T13:15:00Z',
        playersCount: 2,
        occurredAt: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
      },
    ],
    loading: false,
  },
};

export const CancelledOnly: Story = {
  args: {
    activities: [
      {
        id: '1',
        activityType: 'cancelled' as const,
        confirmationCode: 'ABC123XY',
        userName: 'John Smith',
        courseName: 'Pine Valley Golf Course',
        teeTime: '2024-03-16T14:30:00Z',
        playersCount: 4,
        occurredAt: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
      },
      {
        id: '2',
        activityType: 'cancelled' as const,
        confirmationCode: 'DEF456AB',
        userName: 'Mike Wilson',
        courseName: 'Oak Hill Country Club',
        teeTime: '2024-03-16T16:45:00Z',
        playersCount: 3,
        occurredAt: new Date(Date.now() - 25 * 60 * 1000).toISOString(),
      },
    ],
    loading: false,
  },
};