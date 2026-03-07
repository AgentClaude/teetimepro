import { Badge } from '../ui/Badge';
import { Card } from '../ui/Card';

interface TournamentResult {
  id: string;
  position: number;
  positionDisplay: string;
  tournamentEntry: {
    id: string;
    user: {
      id: string;
      firstName: string;
      lastName: string;
    };
    teamName?: string;
  };
  totalStrokes: number;
  totalToPar: number;
  toParDisplay: string;
  tied: boolean;
  prizeAwarded: boolean;
  finalized: boolean;
}

interface TournamentPrize {
  id: string;
  position: number;
  prizeType: string;
  description: string;
  amountDisplay: string;
  awarded: boolean;
  awardedTo?: {
    id: string;
  };
}

export interface ResultsTableProps {
  results: TournamentResult[];
  prizes?: TournamentPrize[];
  title?: string;
  showPrizes?: boolean;
  className?: string;
}

function scoreColorClass(toPar: number): string {
  if (toPar < 0) return "text-red-600 font-semibold";
  if (toPar === 0) return "text-rough-700";
  return "text-rough-500";
}

function getPrizeForPosition(prizes: TournamentPrize[], position: number, entryId: string): TournamentPrize | null {
  if (!prizes) return null;
  
  return prizes.find(p => 
    p.position === position && 
    p.awarded && 
    p.awardedTo?.id === entryId
  ) || null;
}

function formatPlayerName(result: TournamentResult): string {
  const user = result.tournamentEntry.user;
  let name = `${user.firstName} ${user.lastName}`;
  
  if (result.tournamentEntry.teamName) {
    name += ` (${result.tournamentEntry.teamName})`;
  }
  
  return name;
}

export function ResultsTable({
  results,
  prizes = [],
  title = "Final Results",
  showPrizes = true,
  className = ""
}: ResultsTableProps) {
  if (!results || results.length === 0) {
    return (
      <Card className={className}>
        <div className="text-center py-8 text-rough-500">
          No results available. Results will appear here once the tournament is finalized.
        </div>
      </Card>
    );
  }

  const sortedResults = [...results].sort((a, b) => {
    if (a.position !== b.position) return a.position - b.position;
    if (a.totalToPar !== b.totalToPar) return a.totalToPar - b.totalToPar;
    return a.totalStrokes - b.totalStrokes;
  });

  return (
    <Card className={className}>
      <div className="mb-4">
        <h3 className="text-lg font-semibold text-rough-900">{title}</h3>
        <p className="text-sm text-rough-500 mt-1">
          {results.length} player{results.length !== 1 ? 's' : ''} • 
          {results.every(r => r.finalized) ? ' Finalized' : ' Preliminary'}
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b-2 border-rough-200 text-rough-600">
              <th className="text-left py-2 px-3 w-12">Pos</th>
              <th className="text-left py-2 px-3">Player</th>
              <th className="text-center py-2 px-3 w-16">To Par</th>
              <th className="text-center py-2 px-3 w-16">Total</th>
              {showPrizes && <th className="text-left py-2 px-3 w-32">Prize</th>}
            </tr>
          </thead>
          <tbody>
            {sortedResults.map((result, idx) => {
              const prize = showPrizes 
                ? getPrizeForPosition(prizes, result.position, result.tournamentEntry.id)
                : null;

              return (
                <tr
                  key={result.id}
                  className={`border-b border-rough-100 hover:bg-fairway-50 transition-colors ${
                    idx < 3 ? 'bg-fairway-50/30' : ''
                  } ${!result.finalized ? 'opacity-60' : ''}`}
                >
                  <td className="py-2.5 px-3 font-medium text-rough-700">
                    {result.positionDisplay}
                    {result.tied && (
                      <Badge variant="secondary" size="sm" className="ml-1">
                        Tied
                      </Badge>
                    )}
                  </td>
                  <td className="py-2.5 px-3">
                    <div className="font-medium text-rough-900">
                      {formatPlayerName(result)}
                    </div>
                    {!result.finalized && (
                      <div className="text-xs text-rough-400 mt-1">
                        Preliminary
                      </div>
                    )}
                  </td>
                  <td
                    className={`text-center py-2.5 px-3 ${scoreColorClass(
                      result.totalToPar
                    )}`}
                  >
                    {result.toParDisplay}
                  </td>
                  <td className="text-center py-2.5 px-3 font-semibold text-rough-800">
                    {result.totalStrokes}
                  </td>
                  {showPrizes && (
                    <td className="py-2.5 px-3">
                      {prize ? (
                        <div>
                          <Badge variant="success" size="sm">
                            {prize.prizeType}
                          </Badge>
                          <div className="text-xs text-rough-600 mt-1">
                            {prize.description}
                          </div>
                          {prize.amountDisplay !== "$0.00" && (
                            <div className="text-xs font-medium text-green-600">
                              {prize.amountDisplay}
                            </div>
                          )}
                        </div>
                      ) : result.prizeAwarded ? (
                        <Badge variant="secondary" size="sm">
                          Prize
                        </Badge>
                      ) : (
                        <span className="text-xs text-rough-400">—</span>
                      )}
                    </td>
                  )}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="mt-4 pt-3 border-t border-rough-200">
        <div className="flex justify-between items-center text-sm text-rough-600">
          <div>
            <span>Tournament field: {results.length} players</span>
          </div>
          <div className="flex gap-4">
            {showPrizes && (
              <span>
                Prizes awarded: {results.filter(r => r.prizeAwarded).length}
              </span>
            )}
            <span>
              {results.filter(r => r.finalized).length === results.length 
                ? '✓ All results finalized' 
                : `${results.filter(r => r.finalized).length}/${results.length} finalized`
              }
            </span>
          </div>
        </div>
      </div>
    </Card>
  );
}