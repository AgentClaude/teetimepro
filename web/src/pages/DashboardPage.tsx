import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { GET_DASHBOARD_STATS, GET_COURSES } from '../graphql/queries';
import { formatCents, formatTime, formatShortDate } from '../lib/utils';
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

export function DashboardPage() {
  const { data: statsData, loading: statsLoading, error: statsError } = useQuery<{
    dashboardStats: DashboardStats;
  }>(GET_DASHBOARD_STATS);

  const { data: coursesData } = useQuery<{ courses: Course[] }>(GET_COURSES);

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

  const maxRevenue = Math.max(...(stats?.weeklyRevenue?.map(d => d.revenueCents) || [0]));

  if (statsError) {
    return (
      <div className="space-y-6">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <Card className="p-6">
          <p className="text-red-600">Error loading dashboard data: {statsError.message}</p>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        {courses.length > 1 && (
          <select className="rounded-md border-gray-300 text-sm">
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
              <div className={`rounded-lg bg-gray-50 p-3 ${stat.color}`}>
                <stat.icon className="h-6 w-6" />
              </div>
              <div>
                <p className="text-sm text-gray-500">{stat.name}</p>
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {/* Upcoming Bookings & Weekly Revenue */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">Upcoming Bookings</h2>
          {statsLoading ? (
            <p className="text-sm text-gray-500">Loading...</p>
          ) : !stats?.upcomingBookings?.length ? (
            <p className="text-sm text-gray-500">No upcoming bookings found.</p>
          ) : (
            <div className="space-y-3">
              {stats.upcomingBookings.map((booking) => (
                <div key={booking.id} className="flex items-center justify-between border-b border-gray-100 pb-3 last:border-b-0">
                  <div className="flex items-center gap-3">
                    <div className="rounded-lg bg-blue-50 p-2">
                      <ClockIcon className="h-4 w-4 text-blue-600" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {booking.confirmationCode} - {booking.userName}
                      </p>
                      <p className="text-xs text-gray-500">
                        {formatTime(booking.teeTime)} • {booking.courseName} • {booking.playersCount} players
                      </p>
                    </div>
                  </div>
                  <div className="text-sm font-medium text-gray-900">
                    {formatCents(booking.totalCents)}
                  </div>
                </div>
              ))}
            </div>
          )}
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">Revenue This Week</h2>
          {statsLoading ? (
            <p className="text-sm text-gray-500">Loading...</p>
          ) : !stats?.weeklyRevenue?.length ? (
            <p className="text-sm text-gray-500">No revenue data available.</p>
          ) : (
            <div className="space-y-2">
              {stats.weeklyRevenue.map((day, index) => (
                <div key={day.date} className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">
                    {formatShortDate(day.date)}
                  </span>
                  <div className="flex items-center gap-2 flex-1 mx-4">
                    <div className="flex-1 bg-gray-200 rounded-full h-2">
                      <div
                        className="bg-green-600 h-2 rounded-full transition-all duration-300"
                        style={{
                          width: maxRevenue > 0 ? `${(day.revenueCents / maxRevenue) * 100}%` : '0%'
                        }}
                      />
                    </div>
                  </div>
                  <span className="text-sm font-medium text-gray-900 min-w-[4rem] text-right">
                    {formatCents(day.revenueCents)}
                  </span>
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}