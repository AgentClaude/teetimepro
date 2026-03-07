import { Card, CardHeader } from '../ui/Card';
import { Badge } from '../ui/Badge';
import type { MembershipAccount } from './types';

interface MemberAccountSummaryProps {
  membership: MembershipAccount;
  onViewStatement?: () => void;
  onChargeAccount?: () => void;
}

const formatCurrency = (cents: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(cents / 100);
};

const tierBadgeVariant = (tier: string) => {
  switch (tier) {
    case 'platinum':
      return 'info' as const;
    case 'gold':
      return 'warning' as const;
    case 'silver':
      return 'neutral' as const;
    default:
      return 'default' as const;
  }
};

const usagePercentage = (balance: number, limit: number): number => {
  if (limit === 0) return 0;
  return Math.min(Math.round((balance / limit) * 100), 100);
};

const usageColor = (percentage: number): string => {
  if (percentage >= 90) return 'bg-red-500';
  if (percentage >= 75) return 'bg-yellow-500';
  return 'bg-fairway-500';
};

export function MemberAccountSummary({
  membership,
  onViewStatement,
  onChargeAccount,
}: MemberAccountSummaryProps) {
  const usage = usagePercentage(
    membership.accountBalanceCents,
    membership.creditLimitCents
  );

  return (
    <Card>
      <CardHeader
        title={membership.user.fullName}
        subtitle={membership.user.email}
        action={
          <Badge variant={tierBadgeVariant(membership.tier)}>
            {membership.tier.charAt(0).toUpperCase() + membership.tier.slice(1)}
          </Badge>
        }
      />

      <div className="space-y-4">
        {/* Balance Bar */}
        <div>
          <div className="flex justify-between text-sm mb-1">
            <span className="text-rough-600">Account Balance</span>
            <span className="font-semibold text-rough-900">
              {formatCurrency(membership.accountBalanceCents)}
            </span>
          </div>
          <div className="w-full bg-rough-100 rounded-full h-2.5">
            <div
              className={`h-2.5 rounded-full transition-all ${usageColor(usage)}`}
              style={{ width: `${usage}%` }}
            />
          </div>
          <div className="flex justify-between text-xs text-rough-500 mt-1">
            <span>
              {formatCurrency(membership.availableCreditCents)} available
            </span>
            <span>
              {formatCurrency(membership.creditLimitCents)} limit
            </span>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-3 gap-4 pt-2 border-t border-rough-100">
          <div className="text-center">
            <p className="text-xs text-rough-500">Outstanding</p>
            <p className="text-lg font-semibold text-rough-900">
              {formatCurrency(membership.accountBalanceCents)}
            </p>
          </div>
          <div className="text-center">
            <p className="text-xs text-rough-500">Available</p>
            <p className="text-lg font-semibold text-fairway-700">
              {formatCurrency(membership.availableCreditCents)}
            </p>
          </div>
          <div className="text-center">
            <p className="text-xs text-rough-500">Usage</p>
            <p className="text-lg font-semibold text-rough-900">{usage}%</p>
          </div>
        </div>

        {/* Actions */}
        <div className="flex gap-2 pt-2">
          {onChargeAccount && (
            <button
              onClick={onChargeAccount}
              className="flex-1 px-4 py-2 bg-fairway-600 text-white rounded-lg hover:bg-fairway-700 text-sm font-medium transition-colors"
            >
              New Charge
            </button>
          )}
          {onViewStatement && (
            <button
              onClick={onViewStatement}
              className="flex-1 px-4 py-2 border border-rough-300 text-rough-700 rounded-lg hover:bg-rough-50 text-sm font-medium transition-colors"
            >
              View Statement
            </button>
          )}
        </div>
      </div>
    </Card>
  );
}
