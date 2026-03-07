import { Card } from '../ui/Card';

interface VoiceAnalytics {
  totalCalls: number;
  completedCalls: number;
  errorRate: number;
  averageDurationSeconds: number;
  bookingConversionRate: number;
}

interface VoiceStatsCardsProps {
  analytics: VoiceAnalytics;
}

export function VoiceStatsCards({ analytics }: VoiceStatsCardsProps) {
  const formatDuration = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  const stats = [
    {
      label: 'Total Calls',
      value: analytics.totalCalls.toLocaleString(),
      icon: '📞',
    },
    {
      label: 'Average Duration',
      value: formatDuration(analytics.averageDurationSeconds),
      icon: '⏱️',
    },
    {
      label: 'Booking Rate',
      value: `${analytics.bookingConversionRate.toFixed(1)}%`,
      icon: '🎯',
      color: analytics.bookingConversionRate > 20 ? 'text-green-600' : undefined,
    },
    {
      label: 'Error Rate',
      value: `${analytics.errorRate.toFixed(1)}%`,
      icon: '⚠️',
      color: analytics.errorRate > 10 ? 'text-red-600' : 
             analytics.errorRate > 5 ? 'text-yellow-600' : 'text-green-600',
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {stats.map((stat, index) => (
        <Card key={index} className="p-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs font-medium uppercase tracking-wider text-gray-500">
                {stat.label}
              </p>
              <p className={`mt-1 text-2xl font-bold ${stat.color || 'text-gray-900'}`}>
                {stat.value}
              </p>
            </div>
            <div className="text-2xl">{stat.icon}</div>
          </div>
        </Card>
      ))}
    </div>
  );
}