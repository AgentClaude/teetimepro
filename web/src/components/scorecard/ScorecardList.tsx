import { useQuery } from '@apollo/client';
import { Card } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { LoadingSpinner } from '../ui/LoadingSpinner';
import { GET_SCORECARDS } from '../../graphql/queries';
import type { Scorecard, ScorecardStatus } from '../../types/scorecard';

interface ScorecardListProps {
  golferProfileId: string;
  statusFilter?: ScorecardStatus;
  onSelect?: (scorecardId: string) => void;
  limit?: number;
}

function formatScoreToPar(score: number | null): string {
  if (score === null) return '-';
  if (score === 0) return 'E';
  return score > 0 ? `+${score}` : `${score}`;
}

function statusBadgeVariant(status: ScorecardStatus): 'success' | 'warning' | 'default' {
  switch (status) {
    case 'COMPLETED':
      return 'success';
    case 'IN_PROGRESS':
      return 'warning';
    case 'ABANDONED':
      return 'default';
  }
}

function statusLabel(status: ScorecardStatus): string {
  switch (status) {
    case 'COMPLETED':
      return 'Completed';
    case 'IN_PROGRESS':
      return 'In Progress';
    case 'ABANDONED':
      return 'Abandoned';
  }
}

export function ScorecardList({
  golferProfileId,
  statusFilter,
  onSelect,
  limit = 20,
}: ScorecardListProps) {
  const { data, loading, error } = useQuery(GET_SCORECARDS, {
    variables: {
      golferProfileId,
      status: statusFilter,
      limit,
    },
  });

  if (loading) return <LoadingSpinner />;
  if (error) return <p className="text-red-600">Error loading scorecards</p>;

  const scorecards: Scorecard[] = data?.scorecards ?? [];

  if (scorecards.length === 0) {
    return (
      <Card className="p-8 text-center">
        <p className="text-rough-500">No scorecards found</p>
        <p className="text-sm text-rough-400 mt-1">Start a round to create your first scorecard</p>
      </Card>
    );
  }

  return (
    <div className="space-y-2">
      {scorecards.map((sc) => (
        <Card
          key={sc.id}
          className="p-4 cursor-pointer hover:bg-rough-50 transition-colors"
          onClick={() => onSelect?.(sc.id)}
          role="button"
          tabIndex={0}
        >
          <div className="flex items-center justify-between">
            <div>
              <h3 className="font-semibold text-rough-900">{sc.course.name}</h3>
              <p className="text-sm text-rough-500">
                {new Date(sc.playedOn).toLocaleDateString()} · {sc.holesPlayed} holes
              </p>
            </div>
            <div className="text-right flex items-center gap-3">
              <div>
                <div className="text-2xl font-bold text-rough-900">
                  {sc.totalStrokes ?? '-'}
                </div>
                <div className="text-xs text-rough-500">
                  {formatScoreToPar(sc.scoreToPar)}
                </div>
              </div>
              <Badge variant={statusBadgeVariant(sc.status)}>
                {statusLabel(sc.status)}
              </Badge>
            </div>
          </div>
          {sc.status === 'IN_PROGRESS' && (
            <div className="mt-2 text-xs text-rough-400">
              {sc.holesCompleted}/{sc.holesPlayed} holes completed
            </div>
          )}
        </Card>
      ))}
    </div>
  );
}
