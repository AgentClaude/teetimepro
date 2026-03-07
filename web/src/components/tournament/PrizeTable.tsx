import { Badge } from '../ui/Badge';
import { Card } from '../ui/Card';

interface TournamentPrize {
  id: string;
  position: number;
  prizeType: string;
  description: string;
  amountDisplay: string;
  awarded: boolean;
  awardedTo?: {
    id: string;
    user: {
      id: string;
      firstName: string;
      lastName: string;
    };
  };
}

export interface PrizeTableProps {
  prizes: TournamentPrize[];
  title?: string;
  showAwarded?: boolean;
  className?: string;
}

function getPrizeTypeColor(prizeType: string): string {
  switch (prizeType.toLowerCase()) {
    case 'cash':
      return 'bg-green-100 text-green-800 border-green-200';
    case 'trophy':
      return 'bg-yellow-100 text-yellow-800 border-yellow-200';
    case 'voucher':
      return 'bg-blue-100 text-blue-800 border-blue-200';
    case 'merchandise':
      return 'bg-purple-100 text-purple-800 border-purple-200';
    case 'custom':
      return 'bg-gray-100 text-gray-800 border-gray-200';
    default:
      return 'bg-gray-100 text-gray-800 border-gray-200';
  }
}

function formatPosition(position: number): string {
  const suffix = ['th', 'st', 'nd', 'rd'];
  const v = position % 100;
  return position + (suffix[(v - 20) % 10] || suffix[v] || suffix[0]);
}

export function PrizeTable({
  prizes,
  title = "Tournament Prizes",
  showAwarded = true,
  className = ""
}: PrizeTableProps) {
  if (!prizes || prizes.length === 0) {
    return (
      <Card className={className}>
        <div className="text-center py-8 text-rough-500">
          No prizes have been defined for this tournament.
        </div>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <div className="mb-4">
        <h3 className="text-lg font-semibold text-rough-900">{title}</h3>
        <p className="text-sm text-rough-500 mt-1">
          {prizes.length} prize{prizes.length !== 1 ? 's' : ''} defined
        </p>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b-2 border-rough-200 text-rough-600">
              <th className="text-left py-2 px-3 w-16">Position</th>
              <th className="text-left py-2 px-3 w-24">Type</th>
              <th className="text-left py-2 px-3">Description</th>
              <th className="text-right py-2 px-3 w-24">Amount</th>
              {showAwarded && <th className="text-left py-2 px-3 w-32">Awarded To</th>}
            </tr>
          </thead>
          <tbody>
            {prizes
              .sort((a, b) => a.position - b.position)
              .map((prize) => (
                <tr
                  key={prize.id}
                  className={`border-b border-rough-100 hover:bg-fairway-50 transition-colors ${
                    prize.position <= 3 ? 'bg-fairway-50/30' : ''
                  }`}
                >
                  <td className="py-2.5 px-3 font-medium text-rough-700">
                    {formatPosition(prize.position)}
                  </td>
                  <td className="py-2.5 px-3">
                    <span
                      className={`inline-flex items-center px-2 py-1 text-xs font-medium rounded-md border ${getPrizeTypeColor(
                        prize.prizeType
                      )}`}
                    >
                      {prize.prizeType}
                    </span>
                  </td>
                  <td className="py-2.5 px-3">
                    <div className="font-medium text-rough-900">
                      {prize.description}
                    </div>
                  </td>
                  <td className="py-2.5 px-3 text-right font-semibold text-rough-800">
                    {prize.amountDisplay !== "$0.00" ? prize.amountDisplay : "—"}
                  </td>
                  {showAwarded && (
                    <td className="py-2.5 px-3">
                      {prize.awarded && prize.awardedTo ? (
                        <div>
                          <Badge variant="success" size="sm">
                            Awarded
                          </Badge>
                          <div className="text-xs text-rough-500 mt-1">
                            {prize.awardedTo.user.firstName} {prize.awardedTo.user.lastName}
                          </div>
                        </div>
                      ) : (
                        <Badge variant="secondary" size="sm">
                          Pending
                        </Badge>
                      )}
                    </td>
                  )}
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      <div className="mt-4 pt-3 border-t border-rough-200">
        <div className="flex justify-between text-sm text-rough-600">
          <span>Total prizes:</span>
          <span className="font-medium">
            {prizes.reduce((sum, prize) => {
              const amount = parseFloat(prize.amountDisplay.replace(/[$,]/g, '')) || 0;
              return sum + amount;
            }, 0).toLocaleString('en-US', { style: 'currency', currency: 'USD' })}
          </span>
        </div>
        {showAwarded && (
          <div className="flex justify-between text-sm text-rough-600 mt-1">
            <span>Awarded:</span>
            <span>
              {prizes.filter(p => p.awarded).length} of {prizes.length}
            </span>
          </div>
        )}
      </div>
    </Card>
  );
}