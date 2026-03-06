interface AuditEntry {
  id: string;
  event: string;
  changedBy: string | null;
  changes: Record<string, unknown>;
  createdAt: string;
}

const FIELD_LABELS: Record<string, string> = {
  status: 'Status',
  players_count: 'Players',
  total_cents: 'Total',
  notes: 'Notes',
  confirmation_code: 'Confirmation Code',
  first_name: 'First Name',
  last_name: 'Last Name',
  email: 'Email',
  phone: 'Phone',
  role: 'Role',
};

function formatValue(key: string, value: unknown): string {
  if (value === null || value === undefined) return '--';
  if (key === 'total_cents' && typeof value === 'number') return `$${(value / 100).toFixed(2)}`;
  return String(value);
}

export function AuditLog({ entries }: { entries: AuditEntry[] }) {
  if (!entries.length) {
    return <p className="text-sm text-gray-500">No activity recorded yet.</p>;
  }

  return (
    <div className="space-y-3">
      {entries.map((entry) => (
        <div key={entry.id} className="rounded-lg border border-gray-200 bg-gray-50 px-4 py-3">
          <div className="mb-1 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                entry.event === 'create' ? 'bg-green-100 text-green-800'
                  : entry.event === 'update' ? 'bg-blue-100 text-blue-800'
                  : 'bg-red-100 text-red-800'
              }`}>
                {entry.event === 'create' ? 'Created' : entry.event === 'update' ? 'Updated' : 'Deleted'}
              </span>
              {entry.changedBy && (
                <span className="text-xs text-gray-600">by {entry.changedBy}</span>
              )}
            </div>
            <span className="text-xs text-gray-500">{new Date(entry.createdAt).toLocaleString()}</span>
          </div>
          <ChangesList event={entry.event} changes={entry.changes} />
        </div>
      ))}
    </div>
  );
}

function ChangesList({ event, changes }: { event: string; changes: Record<string, unknown> }) {
  const entries = Object.entries(changes);
  if (!entries.length) return null;

  if (event === 'create') {
    return (
      <div className="mt-1 flex flex-wrap gap-x-4 gap-y-0.5">
        {entries.map(([key, value]) => (
          <span key={key} className="text-xs text-gray-600">
            <span className="font-medium">{FIELD_LABELS[key] || key}</span>: {formatValue(key, value)}
          </span>
        ))}
      </div>
    );
  }

  return (
    <div className="mt-1 space-y-0.5">
      {entries.map(([key, value]) => {
        const [oldVal, newVal] = Array.isArray(value) ? value : [null, value];
        return (
          <div key={key} className="text-xs text-gray-600">
            <span className="font-medium">{FIELD_LABELS[key] || key}</span>:{' '}
            {oldVal !== null && (
              <><span className="text-red-600 line-through">{formatValue(key, oldVal)}</span> → </>
            )}
            <span className="text-green-700 font-medium">{formatValue(key, newVal)}</span>
          </div>
        );
      })}
    </div>
  );
}
