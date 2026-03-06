import { useParams, useNavigate, Link } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { GET_VOICE_CALL_LOG } from '../graphql/queries';
import type { VoiceCallLog, TranscriptEntry } from '../types';

export function CallLogPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, loading } = useQuery(GET_VOICE_CALL_LOG, { variables: { id } });
  const log: VoiceCallLog | null = data?.voiceCallLog || null;

  function formatDuration(seconds: number | null) {
    if (!seconds) return '--';
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return m > 0 ? `${m}m ${s}s` : `${s}s`;
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="secondary" size="sm" onClick={() => navigate('/settings')}>
          &larr; Back to Settings
        </Button>
        <h1 className="text-2xl font-bold text-gray-900">Call Log</h1>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading...</p>
      ) : !log ? (
        <p className="text-sm text-gray-500">Call log not found.</p>
      ) : (
        <>
          {/* Call Info */}
          <Card className="p-6">
            <div className="grid grid-cols-2 gap-x-8 gap-y-3 sm:grid-cols-4">
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Channel</dt>
                <dd className="mt-1">
                  <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                    log.channel === 'twilio' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'
                  }`}>
                    {log.channel === 'twilio' ? 'Phone' : 'Browser'}
                  </span>
                </dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Course</dt>
                <dd className="mt-1 text-sm text-gray-900">{log.courseName || '--'}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Caller</dt>
                <dd className="mt-1 text-sm text-gray-900">{log.callerName || log.callerPhone || '--'}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Duration</dt>
                <dd className="mt-1 text-sm text-gray-900">{formatDuration(log.durationSeconds)}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Started</dt>
                <dd className="mt-1 text-sm text-gray-900">{new Date(log.startedAt).toLocaleString()}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Messages</dt>
                <dd className="mt-1 text-sm text-gray-900">{log.summary?.message_count || 0}</dd>
              </div>
              <div>
                <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">API Calls</dt>
                <dd className="mt-1 text-sm text-gray-900">{log.summary?.function_calls || 0}</dd>
              </div>
            </div>
          </Card>

          {/* Linked Booking */}
          {log.summary?.booking_created && (
            <Card className="p-6">
              <h2 className="mb-3 text-lg font-semibold text-gray-900">Booking Created</h2>
              <Link
                to={`/bookings`}
                className="block rounded-lg border border-green-200 bg-green-50 p-4 transition hover:bg-green-100"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-6">
                    <div>
                      <div className="text-xs font-medium uppercase tracking-wider text-gray-500">Confirmation</div>
                      <div className="mt-0.5 font-mono text-sm font-semibold text-gray-900">{log.summary.confirmation_code}</div>
                    </div>
                    {log.summary.booking_date && (
                      <div>
                        <div className="text-xs font-medium uppercase tracking-wider text-gray-500">Tee Time</div>
                        <div className="mt-0.5 text-sm text-gray-900">
                          {new Date(log.summary.booking_date + 'T00:00:00').toLocaleDateString()} at {log.summary.booking_time}
                        </div>
                      </div>
                    )}
                    {log.summary.booking_players && (
                      <div>
                        <div className="text-xs font-medium uppercase tracking-wider text-gray-500">Players</div>
                        <div className="mt-0.5 text-sm text-gray-900">{log.summary.booking_players}</div>
                      </div>
                    )}
                  </div>
                  <div className="flex items-center gap-3">
                    {log.summary.booking_status && (
                      <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                        log.summary.booking_status === 'confirmed' ? 'bg-green-100 text-green-800'
                          : log.summary.booking_status === 'cancelled' ? 'bg-red-100 text-red-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}>
                        {log.summary.booking_status}
                      </span>
                    )}
                    <span className="text-sm font-medium text-green-600">View →</span>
                  </div>
                </div>
              </Link>
            </Card>
          )}

          {/* Transcript */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Transcript</h2>
            {log.transcript && log.transcript.length > 0 ? (
              <div className="space-y-3">
                {log.transcript.map((entry: TranscriptEntry, i: number) => (
                  <TranscriptRow key={i} entry={entry} />
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-500">No transcript available.</p>
            )}
          </Card>
        </>
      )}
    </div>
  );
}

function TranscriptRow({ entry }: { entry: TranscriptEntry }) {
  if (entry.type === 'transcript') {
    const isUser = entry.role === 'user';
    return (
      <div className={`flex ${isUser ? 'justify-start' : 'justify-end'}`}>
        <div className={`max-w-[80%] rounded-lg px-4 py-2 ${
          isUser ? 'bg-gray-100 text-gray-900' : 'bg-green-600 text-white'
        }`}>
          <div className="mb-0.5 text-xs font-medium opacity-70">
            {isUser ? 'Caller' : 'Agent'}
            <span className="ml-2 font-normal">{new Date(entry.timestamp).toLocaleTimeString()}</span>
          </div>
          <div className="text-sm">{entry.content}</div>
        </div>
      </div>
    );
  }

  if (entry.type === 'function_call') {
    let argsDisplay = entry.arguments || '';
    try {
      argsDisplay = JSON.stringify(JSON.parse(argsDisplay), null, 2);
    } catch {
      // keep as-is
    }

    return (
      <div className="mx-4 rounded border border-amber-200 bg-amber-50 px-4 py-2">
        <div className="mb-1 flex items-center gap-2">
          <span className="inline-flex items-center rounded bg-amber-200 px-1.5 py-0.5 text-xs font-mono font-medium text-amber-900">
            API Call
          </span>
          <span className="text-xs font-semibold text-amber-800">{entry.name}</span>
          <span className="text-xs text-amber-600">{new Date(entry.timestamp).toLocaleTimeString()}</span>
        </div>
        <pre className="mt-1 overflow-x-auto whitespace-pre-wrap text-xs text-amber-900">{argsDisplay}</pre>
      </div>
    );
  }

  if (entry.type === 'function_result') {
    const resultStr = typeof entry.result === 'object'
      ? JSON.stringify(entry.result, null, 2)
      : String(entry.result);

    const isSuccess = entry.result && typeof entry.result === 'object' && (
      ('success' in entry.result && entry.result.success) ||
      ('available' in entry.result && entry.result.available)
    );
    const isError = entry.result && typeof entry.result === 'object' && 'error' in entry.result;

    return (
      <div className={`mx-4 rounded border px-4 py-2 ${
        isError
          ? 'border-red-200 bg-red-50'
          : isSuccess
          ? 'border-green-200 bg-green-50'
          : 'border-gray-200 bg-gray-50'
      }`}>
        <div className="mb-1 flex items-center gap-2">
          <span className={`inline-flex items-center rounded px-1.5 py-0.5 text-xs font-mono font-medium ${
            isError ? 'bg-red-200 text-red-900' : isSuccess ? 'bg-green-200 text-green-900' : 'bg-gray-200 text-gray-900'
          }`}>
            Result
          </span>
          <span className="text-xs font-semibold text-gray-700">{entry.name}</span>
          <span className="text-xs text-gray-500">{new Date(entry.timestamp).toLocaleTimeString()}</span>
        </div>
        <pre className="mt-1 overflow-x-auto whitespace-pre-wrap text-xs text-gray-800">{resultStr}</pre>
      </div>
    );
  }

  return null;
}
