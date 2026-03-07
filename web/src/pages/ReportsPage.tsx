import { useState } from 'react';
import { useQuery } from '@apollo/client';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import { Card } from '../components/ui/Card';
import { useCourse } from '../contexts/CourseContext';
import { GET_REPORTS_SUMMARY } from '../graphql/queries';

const PERIOD_OPTIONS = [
  { label: '7 days', value: 7 },
  { label: '14 days', value: 14 },
  { label: '30 days', value: 30 },
  { label: '90 days', value: 90 },
];

export function ReportsPage() {
  const { selectedCourseId } = useCourse();
  const [days, setDays] = useState(30);
  const { data, loading } = useQuery(GET_REPORTS_SUMMARY, {
    variables: { courseId: selectedCourseId || undefined, days },
  });

  const report = data?.reportsSummary;

  const chartData = (report?.daily || []).map((d: { date: string; bookings: number; revenue: number }) => ({
    ...d,
    date: new Date(d.date + 'T00:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
    revenueDollars: d.revenue / 100,
  }));

  const statusBreakdown = report?.status_breakdown || {};

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Reports</h1>
        <div className="flex items-center gap-2">
          {PERIOD_OPTIONS.map((opt) => (
            <button
              key={opt.value}
              onClick={() => setDays(opt.value)}
              className={`rounded-md px-3 py-1.5 text-sm font-medium transition ${
                days === opt.value
                  ? 'bg-green-600 text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading reports...</p>
      ) : !report ? (
        <p className="text-sm text-gray-500">No data available.</p>
      ) : (
        <>
          {/* Summary Stats */}
          <div className="grid grid-cols-2 gap-4 lg:grid-cols-6">
            <StatCard label="Today's Bookings" value={report.today_bookings} />
            <StatCard label="Today's Revenue" value={`$${(report.today_revenue / 100).toFixed(0)}`} />
            <StatCard label={`${days}d Bookings`} value={report.total_bookings} />
            <StatCard label={`${days}d Revenue`} value={`$${(report.total_revenue / 100).toFixed(0)}`} />
            <StatCard label="Total Customers" value={report.total_customers} />
            <StatCard label="Cancel Rate" value={`${report.cancellation_rate}%`} color={report.cancellation_rate > 10 ? 'text-red-600' : undefined} />
          </div>

          {/* Bookings Chart */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Bookings per Day</h2>
            {chartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="date" tick={{ fontSize: 11 }} interval={Math.max(0, Math.floor(chartData.length / 8) - 1)} />
                  <YAxis tick={{ fontSize: 11 }} allowDecimals={false} />
                  <Tooltip />
                  <Bar dataKey="bookings" fill="#16a34a" radius={[3, 3, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-sm text-gray-500">No booking data for this period.</p>
            )}
          </Card>

          {/* Revenue Chart */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Revenue per Day</h2>
            {chartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                  <XAxis dataKey="date" tick={{ fontSize: 11 }} interval={Math.max(0, Math.floor(chartData.length / 8) - 1)} />
                  <YAxis tick={{ fontSize: 11 }} tickFormatter={(v) => `$${v}`} />
                  <Tooltip formatter={(value: number) => [`$${value.toFixed(2)}`, 'Revenue']} />
                  <Line type="monotone" dataKey="revenueDollars" stroke="#16a34a" strokeWidth={2} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-sm text-gray-500">No revenue data for this period.</p>
            )}
          </Card>

          {/* Status Breakdown */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Booking Status Breakdown</h2>
            <div className="flex flex-wrap gap-4">
              {Object.entries(statusBreakdown).map(([status, count]) => (
                <div key={status} className="flex items-center gap-2">
                  <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                    status === 'confirmed' ? 'bg-green-100 text-green-800'
                      : status === 'cancelled' ? 'bg-red-100 text-red-800'
                      : status === 'checked_in' ? 'bg-blue-100 text-blue-800'
                      : status === 'completed' ? 'bg-gray-100 text-gray-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {status}
                  </span>
                  <span className="text-sm font-semibold text-gray-900">{count as number}</span>
                </div>
              ))}
            </div>
          </Card>
        </>
      )}
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: string | number; color?: string }) {
  return (
    <Card className="p-4">
      <p className="text-xs font-medium uppercase tracking-wider text-gray-500">{label}</p>
      <p className={`mt-1 text-2xl font-bold ${color || 'text-gray-900'}`}>{value}</p>
    </Card>
  );
}
