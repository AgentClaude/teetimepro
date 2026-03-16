import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { formatCents, formatShortDate } from '../../lib/utils';

interface RevenueData {
  date: string;
  revenueCents: number;
}

interface RevenueChartProps {
  data: RevenueData[];
  loading?: boolean;
}

interface TooltipProps {
  active?: boolean;
  payload?: Array<{
    value: number;
    name: string;
  }>;
  label?: string;
}

function CustomTooltip({ active, payload, label }: TooltipProps) {
  if (active && payload && payload.length) {
    return (
      <div className="bg-white dark:bg-gray-800 p-3 rounded-lg shadow-lg border border-gray-200 dark:border-gray-700">
        <p className="text-sm text-gray-600 dark:text-gray-400">{formatShortDate(label || '')}</p>
        <p className="text-sm font-semibold text-green-600 dark:text-green-400">
          Revenue: {formatCents(payload[0].value)}
        </p>
      </div>
    );
  }
  return null;
}

export function RevenueChart({ data, loading }: RevenueChartProps) {
  if (loading) {
    return (
      <div className="h-64 flex items-center justify-center">
        <p className="text-sm text-gray-500 dark:text-gray-400">Loading...</p>
      </div>
    );
  }

  if (!data.length) {
    return (
      <div className="h-64 flex items-center justify-center">
        <p className="text-sm text-gray-500 dark:text-gray-400">No revenue data available.</p>
      </div>
    );
  }

  const chartData = data.map(item => ({
    ...item,
    formattedDate: formatShortDate(item.date),
  }));

  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
          <defs>
            <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#059669" stopOpacity={0.8} />
              <stop offset="95%" stopColor="#059669" stopOpacity={0.1} />
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" className="stroke-gray-200 dark:stroke-gray-700" />
          <XAxis 
            dataKey="formattedDate"
            className="text-xs fill-gray-600 dark:fill-gray-400"
            tick={{ fontSize: 12 }}
          />
          <YAxis 
            tickFormatter={(value: number) => formatCents(value)}
            className="text-xs fill-gray-600 dark:fill-gray-400"
            tick={{ fontSize: 12 }}
            width={80}
          />
          <Tooltip content={<CustomTooltip />} />
          <Area
            type="monotone"
            dataKey="revenueCents"
            stroke="#059669"
            fillOpacity={1}
            fill="url(#revenueGradient)"
            strokeWidth={2}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}