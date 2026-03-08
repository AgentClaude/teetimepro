import React from 'react';

interface PrepaidPackageInfo {
  name: string;
  packageType: 'ROUND_PACK' | 'TIME_PASS' | 'VALUE_CARD';
}

interface PrepaidPurchase {
  id: string;
  code: string;
  status: string;
  roundsRemaining: number | null;
  balance: { amountCents: number; currency: string } | null;
  purchasedAt: string;
  expiresAt: string | null;
  usable: boolean;
  totalRoundsUsed: number;
  prepaidPackage: PrepaidPackageInfo;
}

interface PrepaidPurchaseListProps {
  purchases: PrepaidPurchase[];
  onRedeem?: (purchaseId: string) => void;
}

const formatCurrency = (cents: number, currency: string = 'USD'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(cents / 100);
};

const formatDate = (iso: string): string => {
  return new Date(iso).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

const statusColors: Record<string, string> = {
  active: 'bg-green-100 text-green-800',
  expired: 'bg-red-100 text-red-800',
  fully_redeemed: 'bg-gray-100 text-gray-800',
  cancelled: 'bg-red-100 text-red-800',
  suspended: 'bg-yellow-100 text-yellow-800',
};

export const PrepaidPurchaseList: React.FC<PrepaidPurchaseListProps> = ({
  purchases,
  onRedeem,
}) => {
  if (purchases.length === 0) {
    return (
      <div className="rounded-lg border border-dashed border-gray-300 p-8 text-center">
        <p className="text-gray-500">No prepaid packages found.</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {purchases.map((purchase) => (
        <div
          key={purchase.id}
          className="flex items-center justify-between rounded-lg border border-gray-200 bg-white p-4"
        >
          <div className="flex-1">
            <div className="flex items-center gap-2">
              <h4 className="font-medium text-gray-900">
                {purchase.prepaidPackage.name}
              </h4>
              <span
                className={`rounded-full px-2 py-0.5 text-xs font-medium ${
                  statusColors[purchase.status] || 'bg-gray-100 text-gray-800'
                }`}
              >
                {purchase.status.replace('_', ' ')}
              </span>
            </div>
            <div className="mt-1 flex gap-4 text-sm text-gray-500">
              <span>Code: {purchase.code}</span>
              <span>Purchased: {formatDate(purchase.purchasedAt)}</span>
              {purchase.expiresAt && (
                <span>Expires: {formatDate(purchase.expiresAt)}</span>
              )}
            </div>
          </div>

          <div className="flex items-center gap-4">
            <div className="text-right">
              {purchase.roundsRemaining !== null && (
                <p className="text-lg font-semibold text-gray-900">
                  {purchase.roundsRemaining}{' '}
                  <span className="text-sm font-normal text-gray-500">
                    rounds left
                  </span>
                </p>
              )}
              {purchase.balance && (
                <p className="text-lg font-semibold text-gray-900">
                  {formatCurrency(
                    purchase.balance.amountCents,
                    purchase.balance.currency
                  )}
                  <span className="text-sm font-normal text-gray-500">
                    {' '}
                    remaining
                  </span>
                </p>
              )}
              {purchase.prepaidPackage.packageType === 'TIME_PASS' && (
                <p className="text-sm text-gray-500">
                  {purchase.totalRoundsUsed} rounds played
                </p>
              )}
            </div>

            {onRedeem && purchase.usable && (
              <button
                onClick={() => onRedeem(purchase.id)}
                className="rounded-lg bg-blue-600 px-3 py-1.5 text-sm font-medium text-white transition-colors hover:bg-blue-700"
              >
                Redeem
              </button>
            )}
          </div>
        </div>
      ))}
    </div>
  );
};

export default PrepaidPurchaseList;
