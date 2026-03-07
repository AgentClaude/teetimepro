import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import { Card } from '../ui/Card';

interface VoiceAnalytics {
  callsByChannel: Array<{ channel: string; count: number }>;
  callsByDay: Array<{ date: string; count: number }>;
  topCallers: Array<{
    phone: string;
    name: string;
    totalCalls: number;
    averageDurationSeconds: number;
  }>;
}

interface VoiceAnalyticsChartsProps {
  analytics: VoiceAnalytics;
}

export function VoiceAnalyticsCharts({ analytics }: VoiceAnalyticsChartsProps) {
  // Format daily data for chart
  const dailyChartData = analytics.callsByDay.map((d) => ({
    ...d,
    date: new Date(d.date + 'T00:00:00').toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
    }),
  }));

  // Format channel data for chart
  const channelChartData = analytics.callsByChannel.map((c) => ({
    ...c,
    channel: c.channel === 'browser' ? 'Web' : 'Phone',
  }));

  // Format top callers for display
  const formatDuration = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      {/* Daily Calls Chart */}
      <Card className="p-6">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Calls per Day</h2>
        {dailyChartData.length > 0 ? (
          <ResponsiveContainer width="100%" height={250}>
            <LineChart data={dailyChartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis
                dataKey="date"
                tick={{ fontSize: 11 }}
                interval={Math.max(0, Math.floor(dailyChartData.length / 6) - 1)}
              />
              <YAxis tick={{ fontSize: 11 }} allowDecimals={false} />
              <Tooltip />
              <Line
                type="monotone"
                dataKey="count"
                stroke="#16a34a"
                strokeWidth={2}
                dot={{ fill: '#16a34a', strokeWidth: 2, r: 4 }}
                activeDot={{ r: 6 }}
              />
            </LineChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-sm text-gray-500">No call data for this period.</p>
        )}
      </Card>

      {/* Calls by Channel Chart */}
      <Card className="p-6">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Calls by Channel</h2>
        {channelChartData.length > 0 ? (
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={channelChartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
              <XAxis dataKey="channel" tick={{ fontSize: 11 }} />
              <YAxis tick={{ fontSize: 11 }} allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="count" fill="#16a34a" radius={[3, 3, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <p className="text-sm text-gray-500">No channel data for this period.</p>
        )}
      </Card>

      {/* Top Callers Table */}
      <Card className="p-6 lg:col-span-2">
        <h2 className="mb-4 text-lg font-semibold text-gray-900">Top Callers</h2>
        {analytics.topCallers.length > 0 ? (
          <div className="overflow-hidden rounded-lg border border-gray-200">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    Caller
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    Phone
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    Total Calls
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                    Avg Duration
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200 bg-white">
                {analytics.topCallers.slice(0, 8).map((caller, index) => (
                  <tr key={caller.phone} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {caller.name}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {caller.phone}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {caller.totalCalls}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatDuration(caller.averageDurationSeconds)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <p className="text-sm text-gray-500">No caller data available.</p>
        )}
      </Card>
    </div>
  );
}