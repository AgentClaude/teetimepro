interface VoiceCall {
  id: string;
  courseId?: string;
  courseName?: string;
  channel: string;
  callerPhone?: string;
  callerName?: string;
  status: string;
  durationSeconds?: number;
  startedAt: string;
  endedAt?: string;
}

interface VoiceCallsTableProps {
  calls: VoiceCall[];
  loading?: boolean;
}

export function VoiceCallsTable({ calls, loading }: VoiceCallsTableProps) {
  const formatDuration = (seconds?: number): string => {
    if (!seconds) return '-';
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  const formatDateTime = (isoString: string): string => {
    return new Date(isoString).toLocaleString('en-US', {
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });
  };

  const getStatusBadge = (status: string) => {
    const baseClasses = 'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium';
    
    switch (status) {
      case 'completed':
        return `${baseClasses} bg-green-100 text-green-800`;
      case 'error':
        return `${baseClasses} bg-red-100 text-red-800`;
      case 'in_progress':
        return `${baseClasses} bg-blue-100 text-blue-800`;
      default:
        return `${baseClasses} bg-gray-100 text-gray-800`;
    }
  };

  const getChannelBadge = (channel: string) => {
    const baseClasses = 'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium';
    
    switch (channel) {
      case 'browser':
        return `${baseClasses} bg-blue-100 text-blue-800`;
      case 'twilio':
        return `${baseClasses} bg-purple-100 text-purple-800`;
      default:
        return `${baseClasses} bg-gray-100 text-gray-800`;
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <p className="text-sm text-gray-500">Loading calls...</p>
      </div>
    );
  }

  if (calls.length === 0) {
    return (
      <div className="flex items-center justify-center p-8">
        <p className="text-sm text-gray-500">No calls found for this period.</p>
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-lg border border-gray-200">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Caller
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Duration
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Status
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Channel
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Course
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
              Started
            </th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200 bg-white">
          {calls.map((call, index) => (
            <tr key={call.id} className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50'}>
              {/* Caller */}
              <td className="px-6 py-4 whitespace-nowrap">
                <div>
                  <div className="text-sm font-medium text-gray-900">
                    {call.callerName || 'Unknown'}
                  </div>
                  {call.callerPhone && (
                    <div className="text-sm text-gray-500">{call.callerPhone}</div>
                  )}
                </div>
              </td>

              {/* Duration */}
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {formatDuration(call.durationSeconds)}
              </td>

              {/* Status */}
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={getStatusBadge(call.status)}>
                  {call.status.replace('_', ' ')}
                </span>
              </td>

              {/* Channel */}
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={getChannelBadge(call.channel)}>
                  {call.channel === 'browser' ? 'Web' : 'Phone'}
                </span>
              </td>

              {/* Course */}
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {call.courseName || '-'}
              </td>

              {/* Started */}
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {formatDateTime(call.startedAt)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}