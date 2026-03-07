import { Badge } from '../ui/Badge';

export interface CustomerFilterValues {
  search: string;
  role: string;
  membershipTier: string;
  loyaltyTier: string;
  minBookings: string;
  maxBookings: string;
  sortBy: string;
  sortDir: string;
}

const INITIAL_FILTERS: CustomerFilterValues = {
  search: '',
  role: '',
  membershipTier: '',
  loyaltyTier: '',
  minBookings: '',
  maxBookings: '',
  sortBy: 'created_at',
  sortDir: 'desc',
};

interface CustomerFiltersProps {
  filters: CustomerFilterValues;
  onChange: (filters: CustomerFilterValues) => void;
  totalCount?: number;
}

const ROLES = [
  { value: '', label: 'All Roles' },
  { value: 'golfer', label: 'Golfer' },
  { value: 'staff', label: 'Staff' },
  { value: 'pro_shop', label: 'Pro Shop' },
  { value: 'manager', label: 'Manager' },
];

const MEMBERSHIP_TIERS = [
  { value: '', label: 'All Memberships' },
  { value: 'platinum', label: 'Platinum' },
  { value: 'gold', label: 'Gold' },
  { value: 'silver', label: 'Silver' },
  { value: 'basic', label: 'Basic' },
  { value: 'none', label: 'No Membership' },
];

const LOYALTY_TIERS = [
  { value: '', label: 'All Loyalty' },
  { value: 'platinum', label: 'Platinum' },
  { value: 'gold', label: 'Gold' },
  { value: 'silver', label: 'Silver' },
  { value: 'bronze', label: 'Bronze' },
  { value: 'none', label: 'Not Enrolled' },
];

const SORT_OPTIONS = [
  { value: 'created_at', label: 'Date Joined' },
  { value: 'name', label: 'Name' },
  { value: 'email', label: 'Email' },
  { value: 'bookings_count', label: 'Bookings' },
];

export { INITIAL_FILTERS };

export function CustomerFilters({ filters, onChange, totalCount }: CustomerFiltersProps) {
  function update(partial: Partial<CustomerFilterValues>) {
    onChange({ ...filters, ...partial });
  }

  const activeFilterCount = [
    filters.role,
    filters.membershipTier,
    filters.loyaltyTier,
    filters.minBookings,
    filters.maxBookings,
  ].filter(Boolean).length;

  function clearFilters() {
    onChange({
      ...INITIAL_FILTERS,
      search: filters.search,
      sortBy: filters.sortBy,
      sortDir: filters.sortDir,
    });
  }

  return (
    <div className="space-y-4">
      {/* Search + Sort Row */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="relative flex-1">
          <svg
            className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-rough-400"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
            />
          </svg>
          <input
            type="text"
            placeholder="Search by name, email, or phone..."
            value={filters.search}
            onChange={(e) => update({ search: e.target.value })}
            className="block w-full rounded-lg border-rough-300 pl-10 pr-4 py-2.5 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          />
        </div>
        <div className="flex items-center gap-2">
          <select
            value={filters.sortBy}
            onChange={(e) => update({ sortBy: e.target.value })}
            className="rounded-lg border-rough-300 py-2.5 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          >
            {SORT_OPTIONS.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
          <button
            onClick={() => update({ sortDir: filters.sortDir === 'asc' ? 'desc' : 'asc' })}
            className="rounded-lg border border-rough-300 p-2.5 text-rough-500 hover:bg-rough-50 transition-colors"
            title={filters.sortDir === 'asc' ? 'Sort ascending' : 'Sort descending'}
          >
            {filters.sortDir === 'asc' ? '↑' : '↓'}
          </button>
        </div>
      </div>

      {/* Filter Row */}
      <div className="flex flex-wrap items-center gap-2">
        <select
          value={filters.role}
          onChange={(e) => update({ role: e.target.value })}
          className="rounded-lg border-rough-300 py-2 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
        >
          {ROLES.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>

        <select
          value={filters.membershipTier}
          onChange={(e) => update({ membershipTier: e.target.value })}
          className="rounded-lg border-rough-300 py-2 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
        >
          {MEMBERSHIP_TIERS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>

        <select
          value={filters.loyaltyTier}
          onChange={(e) => update({ loyaltyTier: e.target.value })}
          className="rounded-lg border-rough-300 py-2 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
        >
          {LOYALTY_TIERS.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>

        <div className="flex items-center gap-1">
          <input
            type="number"
            placeholder="Min"
            value={filters.minBookings}
            onChange={(e) => update({ minBookings: e.target.value })}
            min={0}
            className="w-20 rounded-lg border-rough-300 py-2 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          />
          <span className="text-xs text-rough-400">–</span>
          <input
            type="number"
            placeholder="Max"
            value={filters.maxBookings}
            onChange={(e) => update({ maxBookings: e.target.value })}
            min={0}
            className="w-20 rounded-lg border-rough-300 py-2 text-sm shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          />
          <span className="text-xs text-rough-500">bookings</span>
        </div>

        {activeFilterCount > 0 && (
          <button
            onClick={clearFilters}
            className="flex items-center gap-1 rounded-lg border border-rough-300 px-3 py-2 text-sm text-rough-600 hover:bg-rough-50 transition-colors"
          >
            Clear filters
            <Badge variant="neutral" size="sm">{activeFilterCount}</Badge>
          </button>
        )}

        {totalCount !== undefined && (
          <span className="ml-auto text-sm text-rough-500">
            {totalCount.toLocaleString()} customer{totalCount !== 1 ? 's' : ''}
          </span>
        )}
      </div>
    </div>
  );
}
