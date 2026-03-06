import { Card } from '../components/ui/Card';
import {
  CalendarDaysIcon,
  CurrencyDollarIcon,
  UserGroupIcon,
  ChartBarIcon,
} from '@heroicons/react/24/outline';

const stats = [
  { name: "Today's Bookings", value: '—', icon: CalendarDaysIcon, color: 'text-blue-600' },
  { name: "Today's Revenue", value: '—', icon: CurrencyDollarIcon, color: 'text-green-600' },
  { name: 'Active Members', value: '—', icon: UserGroupIcon, color: 'text-purple-600' },
  { name: 'Utilization', value: '—', icon: ChartBarIcon, color: 'text-amber-600' },
];

export function DashboardPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
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

      {/* Placeholder sections */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">Upcoming Bookings</h2>
          <p className="text-sm text-gray-500">Connect your tee sheet to see upcoming bookings.</p>
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">Revenue This Week</h2>
          <p className="text-sm text-gray-500">Revenue chart will appear once bookings are processed.</p>
        </Card>
      </div>
    </div>
  );
}
