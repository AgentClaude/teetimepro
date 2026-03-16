import { useState } from 'react';
import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { GET_DASHBOARD_STATS, GET_COURSES, GET_UTILIZATION_HEAT_MAP, GET_RECENT_ACTIVITY } from '../graphql/queries';
import { formatCents, formatTime } from '../lib/utils';
import { RevenueChart } from '../components/dashboard/RevenueChart';
import { UtilizationHeatMap } from '../components/dashboard/UtilizationHeatMap';
import RecentActivityFeed from '../components/dashboard/RecentActivityFeed';
import type { UtilizationHeatMap as UtilizationHeatMapType } from '../types';
import {
  CalendarDaysIcon,
  CurrencyDollarIcon,
  UserGroupIcon,
  ChartBarIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';

interface DashboardStats {
  todaysBookings: number;
  todaysRevenueCents: number;
  activeMembers: number;
  utilizationPercentage: number;
  upcomingBookings: Array<{
    id: string;
    confirmationCode: string;
    userName: string;
    courseName: string;
    teeTime: string;
    playersCount: number;
    totalCents: number;
  }>;
  weeklyRevenue: Array<{
    date: string;
    revenueCents: number;
  }>;
}

interface Course {
  id: string;
  name: string;
}

interface RecentActivity {
  id: string;
  activityType: 'booked' | 'cancelled' | 'checked_in' | 'completed' | 'no_show';
  confirmationCode: string;
  userName: string;
  courseName: string;
  teeTime: string;
  playersCount: number;
  occurredAt: string;
}

export function DashboardPage() {
  const [selectedCourseId, setSelectedCourseId] = useState<string>('');

  // Get date range for utilization heatmap (last 7 days)
  const endDate = new Date().toISOString().split('T')[0];
  const startDate = new Date(Date.now() - 6 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

  const { data: statsData, loading: statsLoading, error: statsError } = useQuery<{
    dashboardStats: DashboardStats;
  }>(GET_DASHBOARD_STATS, {
    variables: {
      courseId: selectedCourseId || undefined,
    },
  });

  const { data: coursesData } = useQuery<{ courses: Course[] }>(GET_COURSES);

  const { data: utilizationData, loading: utilizationLoading } = useQuery<{
    utilizationHeatMap: UtilizationHeatMapType;
  }>(GET_UTILIZATION_HEAT_MAP, {
    variables: {
      courseId: selectedCourseId || undefined,
      startDate,
      endDate,
    },
  });

  const { data: activityData, loading: activityLoading } = useQuery<{
    recentActivity: RecentActivity[];
  }>(GET_RECENT_ACTIVITY, {
    variables: {
      courseId: selectedCourseId || undefined,
      limit: 20,
    },
  });

  const stats = statsData?.dashboardStats;
  const courses = coursesData?.courses || [];

  const statsCards = [
    { 
      name: "Today's Bookings", 
      value: statsLoading ? '—' : (stats?.todaysBookings?.toString() || '0'), 
      icon: CalendarDaysIcon, 
      color: 'text-blue-600' 
    },
    { 
      name: "Today's Revenue", 
      value: statsLoading ? '—' : formatCents(stats?.todaysRevenueCents || 0), 
      icon: CurrencyDollarIcon, 
      color: 'text-green-600' 
    },
    { 
      name: 'Active Members', 
      value: statsLoading ? '—' : (stats?.activeMembers?.toString() || '0'), 
      icon: UserGroupIcon, 
      color: 'text-purple-600' 
    },
    { 
      name: 'Utilization', 
      value: statsLoading ? '—' : `${(stats?.utilizationPercentage || 0).toFixed(1)}%`, 
      icon: ChartBarIcon, 
      color: 'text-amber-600' 
    },
  ];

  if (statsError) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Dashboard</h1>
        <Card className="p-6">
          <p className="text-red-600 dark:text-red-400">Error loading dashboard data: {statsError.message}</p>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">Dashboard</h1>
        {courses.length > 1 && (
          <select 
            className="rounded-md border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 text-sm"
            value={selectedCourseId}
            onChange={(e) => setSelectedCourseId(e.target.value)}
          >
            <option value="">All Courses</option>
            {courses.map((course) => (
              <option key={course.id} value={course.id}>
                {course.name}
              </option>
            ))}
          </select>
        )}
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {statsCards.map((stat) => (
          <Card key={stat.name} className="p-6">
            <div className="flex items-center gap-4">
              <div className={`rounded-lg bg-gray-50 dark:bg-gray-800 p-3 ${stat.color}`}>
                <stat.icon className="h-6 w-6" />
              </div>
              <div>
                <p className="text-sm text-gray-500 dark:text-gray-400">{stat.name}</p>
                <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{stat.value}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {/* Upcoming Bookings & Weekly Revenue */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900 dark:text-gray-100">Upcoming Bookings</h2>
          {statsLoading ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">Loading...</p>
          ) : !stats?.upcomingBookings?.length ? (
            <p className="text-sm text-gray-500 dark:text-gray-400">No upcoming bookings found.</p>
          ) : (
            <div className="space-y-3">
              {stats.upcomingBookings.map((booking) => (
                <div key={booking.id} className="flex items-center justify-between border-b border-gray-100 dark:border-gray-700 pb-3 last:border-b-0">
                  <div className="flex items-center gap-3">
                    <div className="rounded-lg bg-blue-50 dark:bg-blue-900/40 p-2">
                      <ClockIcon className="h-4 w-4 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
                        {booking.confirmationCode} - {booking.userName}
                      </p>
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        {formatTime(booking.teeTime)} • {booking.courseName} • {booking.playersCount} players
                      </p>
                    </div>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-gray-100">
                    {formatCents(booking.totalCents)}
                  </div>
                </div>
              ))}
            </div>
          )}
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900 dark:text-gray-100">Revenue This Week</h2>
          <RevenueChart 
            data={stats?.weeklyRevenue || []}
            loading={statsLoading}
          />
        </Card>
      </div>

      {/* Recent Activity Feed */}
      <div>
        <RecentActivityFeed 
          activities={activityData?.recentActivity || []}
          loading={activityLoading}
        />
      </div>

      {/* Utilization Heat Map */}
      <div>
        <UtilizationHeatMap
          cells={utilizationData?.utilizationHeatMap.cells || []}
          summary={utilizationData?.utilizationHeatMap.summary || {
            overallUtilization: 0,
            totalBookedPlayers: 0,
            totalCapacity: 0,
            peakHour: null,
            peakHourUtilization: 0,
            peakDayOfWeek: null,
            peakDayUtilization: 0,
            dateRangeDays: 7,
          }}
          loading={utilizationLoading}
        />
      </div>
    </div>
  );
}
