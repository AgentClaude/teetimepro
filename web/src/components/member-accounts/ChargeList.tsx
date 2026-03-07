import { Badge } from '../ui/Badge';
import { Card, CardHeader } from '../ui/Card';
import { format } from 'date-fns';
import type { MemberAccountCharge } from './types';
import { CHARGE_TYPE_LABELS } from './types';

interface ChargeListProps {
  charges: MemberAccountCharge[];
  onVoidCharge?: (chargeId: string) => void;
  loading?: boolean;
  showMemberName?: boolean;
}

const formatCurrency = (cents: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(cents / 100);
};

const statusVariant = (status: string) => {
  switch (status) {
    case 'posted':
      return 'success' as const;
    case 'pending':
      return 'warning' as const;
    case 'voided':
      return 'danger' as const;
    case 'paid':
      return 'info' as const;
    default:
      return 'neutral' as const;
  }
};

const chargeTypeIcon = (type: string): string => {
  switch (type) {
    case 'fnb':
      return '🍽️';
    case 'booking':
      return '⛳';
    case 'pro_shop':
      return '🏌️';
    case 'dues':
      return '📋';
    default:
      return '💰';
  }
};

export function ChargeList({
  charges,
  onVoidCharge,
  loading = false,
  showMemberName = false,
}: ChargeListProps) {
  if (loading) {
    return (
      <Card>
        <div className="animate-pulse space-y-4">
          {[1, 2, 3].map((i) => (
            <div key={i} className="flex items-center gap-4">
              <div className="h-10 w-10 bg-rough-200 rounded-full" />
              <div className="flex-1 space-y-2">
                <div className="h-4 bg-rough-200 rounded w-3/4" />
                <div className="h-3 bg-rough-200 rounded w-1/2" />
              </div>
              <div className="h-6 w-16 bg-rough-200 rounded" />
            </div>
          ))}
        </div>
      </Card>
    );
  }

  if (charges.length === 0) {
    return (
      <Card>
        <div className="text-center py-8 text-rough-500">
          <p className="text-lg">No charges found</p>
          <p className="text-sm mt-1">Member account charges will appear here</p>
        </div>
      </Card>
    );
  }

  return (
    <Card padding="none">
      <div className="p-6 pb-0">
        <CardHeader title="Account Charges" subtitle={`${charges.length} charge(s)`} />
      </div>
      <div className="divide-y divide-rough-100">
        {charges.map((charge) => (
          <div
            key={charge.id}
            className="flex items-center gap-4 px-6 py-4 hover:bg-rough-50 transition-colors"
          >
            {/* Icon */}
            <div className="flex-shrink-0 h-10 w-10 rounded-full bg-rough-100 flex items-center justify-center text-lg">
              {chargeTypeIcon(charge.chargeType)}
            </div>

            {/* Details */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <p className="text-sm font-medium text-rough-900 truncate">
                  {charge.description}
                </p>
                <Badge variant={statusVariant(charge.status)}>
                  {charge.status}
                </Badge>
              </div>
              <div className="flex items-center gap-2 mt-0.5">
                <span className="text-xs text-rough-500">
                  {CHARGE_TYPE_LABELS[charge.chargeType] ?? charge.chargeType}
                </span>
                {showMemberName && charge.memberName && (
                  <>
                    <span className="text-xs text-rough-300">•</span>
                    <span className="text-xs text-rough-500">
                      {charge.memberName}
                    </span>
                  </>
                )}
                <span className="text-xs text-rough-300">•</span>
                <span className="text-xs text-rough-500">
                  {format(new Date(charge.createdAt), 'MMM d, yyyy h:mm a')}
                </span>
                <span className="text-xs text-rough-300">•</span>
                <span className="text-xs text-rough-500">
                  by {charge.chargedBy.fullName}
                </span>
              </div>
            </div>

            {/* Amount */}
            <div className="flex items-center gap-3">
              <span
                className={`text-sm font-semibold ${
                  charge.status === 'voided'
                    ? 'text-rough-400 line-through'
                    : 'text-rough-900'
                }`}
              >
                {formatCurrency(charge.amountCents)}
              </span>

              {onVoidCharge && charge.voidable && (
                <button
                  onClick={() => onVoidCharge(charge.id)}
                  className="text-xs text-red-600 hover:text-red-800 font-medium px-2 py-1 rounded hover:bg-red-50 transition-colors"
                >
                  Void
                </button>
              )}
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}
