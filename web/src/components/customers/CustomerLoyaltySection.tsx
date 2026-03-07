import { Card, CardHeader } from '../ui/Card';
import { Badge } from '../ui/Badge';

interface LoyaltyTransaction {
  id: string;
  transactionType: string;
  points: number;
  description: string;
  balanceAfter: number;
  createdAt: string;
}

interface LoyaltyAccount {
  id: string;
  pointsBalance: number;
  lifetimePoints: number;
  tier: string;
  tierName: string;
  pointsNeededForNextTier: number;
  recentTransactions: LoyaltyTransaction[];
}

interface CustomerLoyaltySectionProps {
  loyaltyAccount: LoyaltyAccount | null | undefined;
  compact?: boolean;
}

function tierBadgeVariant(tier: string) {
  switch (tier) {
    case 'platinum': return 'info' as const;
    case 'gold': return 'warning' as const;
    case 'silver': return 'secondary' as const;
    default: return 'neutral' as const;
  }
}

function transactionTypeVariant(type: string) {
  switch (type) {
    case 'earn': return 'success' as const;
    case 'redeem': return 'warning' as const;
    case 'adjust': return 'info' as const;
    case 'expire': return 'danger' as const;
    default: return 'neutral' as const;
  }
}

export function CustomerLoyaltySection({ loyaltyAccount, compact = false }: CustomerLoyaltySectionProps) {
  if (!loyaltyAccount) {
    return (
      <Card>
        <CardHeader title="Loyalty Program" />
        <div className="flex flex-col items-center justify-center py-8 text-center">
          <p className="text-sm text-rough-500">Not enrolled in loyalty program</p>
          <p className="text-xs text-rough-400 mt-1">Customer has not been enrolled in a loyalty program yet.</p>
        </div>
      </Card>
    );
  }

  const progressToNextTier = loyaltyAccount.pointsNeededForNextTier > 0
    ? Math.min(100, Math.round((loyaltyAccount.lifetimePoints / (loyaltyAccount.lifetimePoints + loyaltyAccount.pointsNeededForNextTier)) * 100))
    : 100;

  const transactions = compact
    ? loyaltyAccount.recentTransactions.slice(0, 5)
    : loyaltyAccount.recentTransactions;

  return (
    <div className={compact ? '' : 'space-y-6'}>
      <Card>
        <CardHeader title="Loyalty Program" />

        {/* Points Summary */}
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-4 mb-6">
          <div className="rounded-lg bg-rough-50 p-3 text-center">
            <p className="text-xs font-medium uppercase tracking-wider text-rough-500">Balance</p>
            <p className="text-xl font-bold text-rough-900 mt-1">
              {loyaltyAccount.pointsBalance.toLocaleString()}
            </p>
            <p className="text-xs text-rough-400">points</p>
          </div>
          <div className="rounded-lg bg-rough-50 p-3 text-center">
            <p className="text-xs font-medium uppercase tracking-wider text-rough-500">Lifetime</p>
            <p className="text-xl font-bold text-rough-900 mt-1">
              {loyaltyAccount.lifetimePoints.toLocaleString()}
            </p>
            <p className="text-xs text-rough-400">earned</p>
          </div>
          <div className="rounded-lg bg-rough-50 p-3 text-center">
            <p className="text-xs font-medium uppercase tracking-wider text-rough-500">Tier</p>
            <div className="mt-1">
              <Badge variant={tierBadgeVariant(loyaltyAccount.tier)}>
                {loyaltyAccount.tierName}
              </Badge>
            </div>
          </div>
          <div className="rounded-lg bg-rough-50 p-3 text-center">
            <p className="text-xs font-medium uppercase tracking-wider text-rough-500">Next Tier</p>
            <p className="text-xl font-bold text-rough-900 mt-1">
              {loyaltyAccount.pointsNeededForNextTier > 0
                ? loyaltyAccount.pointsNeededForNextTier.toLocaleString()
                : '—'}
            </p>
            <p className="text-xs text-rough-400">
              {loyaltyAccount.pointsNeededForNextTier > 0 ? 'points needed' : 'max tier'}
            </p>
          </div>
        </div>

        {/* Progress Bar */}
        {loyaltyAccount.pointsNeededForNextTier > 0 && (
          <div className="mb-6">
            <div className="flex items-center justify-between text-xs text-rough-500 mb-1">
              <span>Progress to next tier</span>
              <span>{progressToNextTier}%</span>
            </div>
            <div className="h-2 w-full rounded-full bg-rough-200">
              <div
                className="h-2 rounded-full bg-fairway-500 transition-all"
                style={{ width: `${progressToNextTier}%` }}
              />
            </div>
          </div>
        )}

        {/* Recent Transactions */}
        <div>
          <h4 className="text-sm font-medium text-rough-700 mb-3">Recent Transactions</h4>
          {transactions.length === 0 ? (
            <p className="text-sm text-rough-500 text-center py-4">No transactions yet</p>
          ) : (
            <div className="divide-y divide-rough-100">
              {transactions.map((tx) => (
                <div key={tx.id} className="flex items-center justify-between py-3">
                  <div className="flex items-center gap-3">
                    <span className={`text-sm font-bold ${tx.points > 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {tx.points > 0 ? '+' : ''}{tx.points}
                    </span>
                    <div>
                      <p className="text-sm text-rough-900">{tx.description}</p>
                      <p className="text-xs text-rough-400">
                        {new Date(tx.createdAt).toLocaleDateString(undefined, {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant={transactionTypeVariant(tx.transactionType)} size="sm">
                      {tx.transactionType}
                    </Badge>
                    <span className="text-xs text-rough-400">
                      bal: {tx.balanceAfter.toLocaleString()}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </Card>
    </div>
  );
}
