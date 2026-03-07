import { useState } from 'react';
import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { useCourse } from '../contexts/CourseContext';
import { GET_VOICE_ANALYTICS, GET_VOICE_CALL_LOGS_PAGINATED } from '../graphql/queries';
import { VoiceAnalyticsCharts } from '../components/voice-analytics/VoiceAnalyticsCharts';
import { VoiceCallsTable } from '../components/voice-analytics/VoiceCallsTable';
import { VoiceStatsCards } from '../components/voice-analytics/VoiceStatsCards';

const DATE_RANGE_OPTIONS = [
  { label: 'Last 7 days', value: 7 },
  { label: 'Last 30 days', value: 30 },
  { label: 'Last 90 days', value: 90 },
];

export function VoiceAnalyticsPage() {
  const { selectedCourseId } = useCourse();
  const [dateRange, setDateRange] = useState(30);

  // Calculate date range
  const endDate = new Date().toISOString().split('T')[0];
  const startDate = new Date(Date.now() - dateRange * 24 * 60 * 60 * 1000)
    .toISOString().split('T')[0];

  const { data: analyticsData, loading: analyticsLoading } = useQuery(GET_VOICE_ANALYTICS, {
    variables: { 
      courseId: selectedCourseId || undefined, 
      startDate, 
      endDate 
    },
  });

  const { data: callLogsData, loading: callLogsLoading } = useQuery(GET_VOICE_CALL_LOGS_PAGINATED, {
    variables: { 
      courseId: selectedCourseId || undefined,
      startDate,
      endDate,
      limit: 20,
      offset: 0
    },
  });

  const analytics = analyticsData?.voiceAnalytics;
  const callLogs = callLogsData?.voiceCallLogs || [];

  const isLoading = analyticsLoading || callLogsLoading;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Voice Analytics</h1>
        <div className="flex items-center gap-2">
          {DATE_RANGE_OPTIONS.map((option) => (
            <button
              key={option.value}
              onClick={() => setDateRange(option.value)}
              className={`rounded-md px-3 py-1.5 text-sm font-medium transition ${
                dateRange === option.value
                  ? 'bg-green-600 text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center p-12">
          <p className="text-sm text-gray-500">Loading voice analytics...</p>
        </div>
      ) : !analytics ? (
        <div className="flex items-center justify-center p-12">
          <p className="text-sm text-gray-500">No voice analytics data available.</p>
        </div>
      ) : (
        <>
          {/* Stats Cards */}
          <VoiceStatsCards analytics={analytics} />

          {/* Charts */}
          <VoiceAnalyticsCharts analytics={analytics} />

          {/* Recent Calls Table */}
          <Card className="p-6">
            <h2 className="mb-6 text-lg font-semibold text-gray-900">Recent Calls</h2>
            <VoiceCallsTable calls={callLogs} loading={callLogsLoading} />
          </Card>
        </>
      )}
    </div>
  );
}