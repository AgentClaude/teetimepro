import { useState } from 'react';
import { useQuery } from '@apollo/client';
import { Card, CardHeader } from '../ui/Card';
import { Button } from '../ui/Button';
import { Badge } from '../ui/Badge';
import { GET_GOLFER_ROUNDS } from '../../graphql/golferProfile';

interface Round {
  id: string;
  courseName: string;
  playedOn: string;
  score: number;
  holesPlayed: number;
  courseRating: number | null;
  slopeRating: number | null;
  differential: number | null;
  teeColor: string | null;
  putts: number | null;
  fairwaysHit: number | null;
  greensInRegulation: number | null;
  notes: string | null;
}

interface PlayHistoryProps {
  profileId: string;
  initialRounds?: Round[];
}

const PAGE_SIZE = 10;

export function PlayHistory({ profileId, initialRounds }: PlayHistoryProps) {
  const [offset, setOffset] = useState(0);

  const { data } = useQuery(GET_GOLFER_ROUNDS, {
    variables: { id: profileId, limit: PAGE_SIZE, offset },
    skip: offset === 0 && !!initialRounds,
  });

  const rounds = offset === 0 && initialRounds ? initialRounds : data?.golferProfile?.rounds ?? [];

  return (
    <Card>
      <CardHeader title="Play History" />
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                Date
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-500">
                Course
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Score
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Holes
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Diff
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Tee
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                Putts
              </th>
              <th className="px-4 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-500">
                GIR
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 bg-white">
            {rounds.map((round: Round) => (
              <tr key={round.id} className="hover:bg-gray-50">
                <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-900">
                  {new Date(round.playedOn).toLocaleDateString()}
                </td>
                <td className="px-4 py-3 text-sm text-gray-900">{round.courseName}</td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm font-semibold text-gray-900">
                  {round.score}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm text-gray-500">
                  {round.holesPlayed}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm text-gray-500">
                  {round.differential?.toFixed(1) ?? '—'}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center">
                  {round.teeColor ? (
                    <Badge variant="default">{round.teeColor}</Badge>
                  ) : (
                    '—'
                  )}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm text-gray-500">
                  {round.putts ?? '—'}
                </td>
                <td className="whitespace-nowrap px-4 py-3 text-center text-sm text-gray-500">
                  {round.greensInRegulation ?? '—'}
                </td>
              </tr>
            ))}
            {rounds.length === 0 && (
              <tr>
                <td colSpan={8} className="px-4 py-8 text-center text-sm text-gray-500">
                  No rounds recorded yet
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
      <div className="flex items-center justify-between border-t border-gray-200 px-4 py-3">
        <Button
          variant="outline"
          size="sm"
          disabled={offset === 0}
          onClick={() => setOffset(Math.max(0, offset - PAGE_SIZE))}
        >
          Previous
        </Button>
        <span className="text-sm text-gray-500">
          Showing {offset + 1}–{offset + rounds.length}
        </span>
        <Button
          variant="outline"
          size="sm"
          disabled={rounds.length < PAGE_SIZE}
          onClick={() => setOffset(offset + PAGE_SIZE)}
        >
          Next
        </Button>
      </div>
    </Card>
  );
}
