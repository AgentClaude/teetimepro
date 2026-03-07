import { Card, CardHeader } from '../ui/Card';
import { Badge } from '../ui/Badge';

interface HandicapRevision {
  id: string;
  handicapIndex: number;
  previousIndex: number | null;
  change: number | null;
  effectiveDate: string;
  source: string;
  roundsUsed: number;
}

interface HandicapHistoryProps {
  revisions: HandicapRevision[];
  currentIndex: number | null;
}

function ChangeIndicator({ change }: { change: number | null }) {
  if (change === null || change === 0) return <span className="text-gray-400">—</span>;

  const isImprovement = change < 0;
  return (
    <span className={isImprovement ? 'text-green-600' : 'text-red-600'}>
      {isImprovement ? '↓' : '↑'} {Math.abs(change).toFixed(1)}
    </span>
  );
}

function sourceLabel(source: string): string {
  switch (source) {
    case 'calculated':
      return 'Auto';
    case 'manual':
      return 'Manual';
    case 'imported':
      return 'Imported';
    default:
      return source;
  }
}

export function HandicapHistory({ revisions, currentIndex: _currentIndex }: HandicapHistoryProps) {
  // Simple sparkline visualization using bars
  const maxIndex = Math.max(...revisions.map((r) => r.handicapIndex), 1);
  const minIndex = Math.min(...revisions.map((r) => r.handicapIndex), 0);
  const range = maxIndex - minIndex || 1;

  return (
    <Card>
      <CardHeader title="Handicap History" />

      {/* Mini chart */}
      {revisions.length > 1 && (
        <div className="border-b border-gray-200 px-4 py-4">
          <div className="flex h-24 items-end gap-1">
            {[...revisions].reverse().map((rev) => {
              const height = ((rev.handicapIndex - minIndex) / range) * 100;
              return (
                <div
                  key={rev.id}
                  className="flex-1 rounded-t bg-green-500 transition-all hover:bg-green-600"
                  style={{ height: `${Math.max(height, 4)}%` }}
                  title={`${rev.effectiveDate}: ${rev.handicapIndex}`}
                />
              );
            })}
          </div>
          <div className="mt-1 flex justify-between text-xs text-gray-400">
            <span>
              {revisions.length > 0 &&
                new Date(revisions[revisions.length - 1].effectiveDate).toLocaleDateString(
                  undefined,
                  { month: 'short', year: '2-digit' }
                )}
            </span>
            <span>
              {revisions.length > 0 &&
                new Date(revisions[0].effectiveDate).toLocaleDateString(undefined, {
                  month: 'short',
                  year: '2-digit',
                })}
            </span>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                Date
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Index
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Change
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Rounds
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Source
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 bg-white">
            {revisions.map((rev) => (
              <tr key={rev.id} className="hover:bg-gray-50">
                <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-900">
                  {new Date(rev.effectiveDate).toLocaleDateString()}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm font-semibold text-gray-900">
                  {rev.handicapIndex.toFixed(1)}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm">
                  <ChangeIndicator change={rev.change} />
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm text-gray-500">
                  {rev.roundsUsed}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center">
                  <Badge variant="default">{sourceLabel(rev.source)}</Badge>
                </td>
              </tr>
            ))}
            {revisions.length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-8 text-center text-sm text-gray-500">
                  No handicap history yet
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </Card>
  );
}
