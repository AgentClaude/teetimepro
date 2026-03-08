import React from 'react';

interface PrepaidPackage {
  id: string;
  name: string;
  description: string | null;
  packageType: 'ROUND_PACK' | 'TIME_PASS' | 'VALUE_CARD';
  roundsIncluded: number | null;
  price: { amountCents: number; currency: string };
  value: { amountCents: number; currency: string } | null;
  validityDays: number | null;
  maxPlayersPerRound: number;
  transferable: boolean;
  available: boolean;
}

interface PrepaidPackageCardProps {
  package: PrepaidPackage;
  onPurchase?: (packageId: string) => void;
  compact?: boolean;
}

const formatCurrency = (cents: number, currency: string = 'USD'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
  }).format(cents / 100);
};

const packageTypeLabel: Record<string, string> = {
  ROUND_PACK: 'Round Pack',
  TIME_PASS: 'Time Pass',
  VALUE_CARD: 'Value Card',
};

const packageTypeIcon: Record<string, string> = {
  ROUND_PACK: '🏌️',
  TIME_PASS: '📅',
  VALUE_CARD: '💳',
};

export const PrepaidPackageCard: React.FC<PrepaidPackageCardProps> = ({
  package: pkg,
  onPurchase,
  compact = false,
}) => {
  return (
    <div
      className={`rounded-lg border ${
        pkg.available
          ? 'border-green-200 bg-white'
          : 'border-gray-200 bg-gray-50 opacity-75'
      } p-4 shadow-sm transition-shadow hover:shadow-md ${
        compact ? 'space-y-2' : 'space-y-3'
      }`}
    >
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xl">{packageTypeIcon[pkg.packageType]}</span>
            <h3 className="text-lg font-semibold text-gray-900">{pkg.name}</h3>
          </div>
          <span className="inline-block mt-1 rounded-full bg-blue-100 px-2 py-0.5 text-xs font-medium text-blue-800">
            {packageTypeLabel[pkg.packageType]}
          </span>
        </div>
        <div className="text-right">
          <p className="text-2xl font-bold text-gray-900">
            {formatCurrency(pkg.price.amountCents, pkg.price.currency)}
          </p>
          {pkg.value && (
            <p className="text-sm text-gray-500">
              {formatCurrency(pkg.value.amountCents, pkg.value.currency)} value
            </p>
          )}
        </div>
      </div>

      {pkg.description && !compact && (
        <p className="text-sm text-gray-600">{pkg.description}</p>
      )}

      <div className="flex flex-wrap gap-3 text-sm text-gray-500">
        {pkg.roundsIncluded && (
          <span className="flex items-center gap-1">
            <span className="font-medium text-gray-700">
              {pkg.roundsIncluded}
            </span>{' '}
            rounds
          </span>
        )}
        {pkg.packageType === 'TIME_PASS' && (
          <span className="flex items-center gap-1">Unlimited rounds</span>
        )}
        {pkg.validityDays && (
          <span className="flex items-center gap-1">
            <span className="font-medium text-gray-700">
              {pkg.validityDays}
            </span>{' '}
            day validity
          </span>
        )}
        <span className="flex items-center gap-1">
          Up to{' '}
          <span className="font-medium text-gray-700">
            {pkg.maxPlayersPerRound}
          </span>{' '}
          players
        </span>
        {pkg.transferable && (
          <span className="rounded bg-purple-100 px-1.5 py-0.5 text-xs text-purple-700">
            Transferable
          </span>
        )}
      </div>

      {onPurchase && (
        <button
          onClick={() => onPurchase(pkg.id)}
          disabled={!pkg.available}
          className={`mt-2 w-full rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
            pkg.available
              ? 'bg-green-600 text-white hover:bg-green-700'
              : 'cursor-not-allowed bg-gray-300 text-gray-500'
          }`}
        >
          {pkg.available ? 'Purchase Package' : 'Unavailable'}
        </button>
      )}
    </div>
  );
};

export default PrepaidPackageCard;
