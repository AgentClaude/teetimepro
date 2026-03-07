import { Card, CardHeader } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { format } from 'date-fns';
import type { MemberAccountStatement } from './types';
import { CHARGE_TYPE_LABELS } from './types';

interface MemberStatementProps {
  statement: MemberAccountStatement;
  onPageChange?: (page: number) => void;
  onVoidCharge?: (chargeId: string) => void;
  onBack?: () => void;
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

export function MemberStatement({
  statement,
  onPageChange,
  onVoidCharge,
  onBack,
}: MemberStatementProps) {
  const { membership, charges } = statement;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          {onBack && (
            <button
              onClick={onBack}
              className="text-rough-500 hover:text-rough-700 transition-colors"
            >
              ← Back
            </button>
          )}
          <div>
            <h2 className="text-xl font-bold text-rough-900">
              Account Statement
            </h2>
            <p className="text-sm text-rough-500">
              {membership.user.fullName}
            </p>
          </div>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <p className="text-xs text-rough-500 uppercase tracking-wide">
            Current Balance
          </p>
          <p className="text-2xl font-bold text-rough-900 mt-1">
            {formatCurrency(statement.currentBalanceCents)}
          </p>
        </Card>
        <Card>
          <p className="text-xs text-rough-500 uppercase tracking-wide">
            Credit Limit
          </p>
          <p className="text-2xl font-bold text-rough-900 mt-1">
            {formatCurrency(statement.creditLimitCents)}
          </p>
        </Card>
        <Card>
          <p className="text-xs text-rough-500 uppercase tracking-wide">
            Available Credit
          </p>
          <p className="text-2xl font-bold text-fairway-700 mt-1">
            {formatCurrency(statement.availableCreditCents)}
          </p>
        </Card>
        <Card>
          <p className="text-xs text-rough-500 uppercase tracking-wide">
            Period Total
          </p>
          <p className="text-2xl font-bold text-rough-900 mt-1">
            {formatCurrency(statement.periodTotalCents)}
          </p>
        </Card>
      </div>

      {/* Charges Table */}
      <Card padding="none">
        <div className="p-6 pb-0">
          <CardHeader
            title="Charges"
            subtitle={`${statement.totalCount} total charge(s)`}
          />
        </div>

        {charges.length === 0 ? (
          <div className="text-center py-8 text-rough-500">
            No charges in this period
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-rough-200 text-left">
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase">
                    Date
                  </th>
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase">
                    Type
                  </th>
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase">
                    Description
                  </th>
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase">
                    Status
                  </th>
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase text-right">
                    Amount
                  </th>
                  <th className="px-6 py-3 text-xs font-medium text-rough-500 uppercase">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-rough-100">
                {charges.map((charge) => (
                  <tr
                    key={charge.id}
                    className="hover:bg-rough-50 transition-colors"
                  >
                    <td className="px-6 py-3 text-sm text-rough-600">
                      {format(new Date(charge.createdAt), 'MMM d, yyyy')}
                    </td>
                    <td className="px-6 py-3 text-sm text-rough-600">
                      {CHARGE_TYPE_LABELS[charge.chargeType] ?? charge.chargeType}
                    </td>
                    <td className="px-6 py-3 text-sm text-rough-900">
                      {charge.description}
                    </td>
                    <td className="px-6 py-3">
                      <Badge variant={statusVariant(charge.status)}>
                        {charge.status}
                      </Badge>
                    </td>
                    <td
                      className={`px-6 py-3 text-sm font-medium text-right ${
                        charge.status === 'voided'
                          ? 'text-rough-400 line-through'
                          : 'text-rough-900'
                      }`}
                    >
                      {formatCurrency(charge.amountCents)}
                    </td>
                    <td className="px-6 py-3">
                      {onVoidCharge && charge.voidable && (
                        <button
                          onClick={() => onVoidCharge(charge.id)}
                          className="text-xs text-red-600 hover:text-red-800 font-medium"
                        >
                          Void
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}

        {/* Pagination */}
        {statement.totalPages > 1 && onPageChange && (
          <div className="flex items-center justify-between px-6 py-4 border-t border-rough-200">
            <p className="text-sm text-rough-500">
              Page {statement.page} of {statement.totalPages}
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => onPageChange(statement.page - 1)}
                disabled={statement.page <= 1}
                className="px-3 py-1 text-sm border border-rough-300 rounded-lg hover:bg-rough-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>
              <button
                onClick={() => onPageChange(statement.page + 1)}
                disabled={statement.page >= statement.totalPages}
                className="px-3 py-1 text-sm border border-rough-300 rounded-lg hover:bg-rough-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </div>
          </div>
        )}
      </Card>
    </div>
  );
}
