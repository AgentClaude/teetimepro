import { useState, useEffect, useCallback } from 'react';
import { useLazyQuery } from '@apollo/client';
import { PREVIEW_GOLFER_SEGMENT } from '../../graphql/queries';

interface FilterCriteria {
  booking_count_min?: number;
  booking_count_max?: number;
  last_booking_within_days?: number;
  last_booking_before_days?: number;
  membership_tier?: string[];
  membership_status?: string;
  total_spent_min?: number;
  total_spent_max?: number;
  signup_within_days?: number;
  signup_before_days?: number;
  handicap_min?: number;
  handicap_max?: number;
}

interface FilterOption {
  key: string;
  label: string;
  group: string;
  type: 'number' | 'select' | 'multiselect';
  options?: { value: string; label: string }[];
  suffix?: string;
  placeholder?: string;
}

const FILTER_OPTIONS: FilterOption[] = [
  { key: 'booking_count_min', label: 'Min bookings', group: 'Booking Activity', type: 'number', placeholder: '0' },
  { key: 'booking_count_max', label: 'Max bookings', group: 'Booking Activity', type: 'number', placeholder: '100' },
  { key: 'last_booking_within_days', label: 'Booked within', group: 'Booking Activity', type: 'number', suffix: 'days' },
  { key: 'last_booking_before_days', label: 'No booking since', group: 'Booking Activity', type: 'number', suffix: 'days' },
  { key: 'total_spent_min', label: 'Min total spent ($)', group: 'Spending', type: 'number', placeholder: '0' },
  { key: 'total_spent_max', label: 'Max total spent ($)', group: 'Spending', type: 'number', placeholder: '10000' },
  {
    key: 'membership_status', label: 'Membership status', group: 'Membership', type: 'select',
    options: [
      { value: 'active', label: 'Active member' },
      { value: 'expired', label: 'Expired member' },
      { value: 'none', label: 'Non-member' },
    ],
  },
  {
    key: 'membership_tier', label: 'Membership tier', group: 'Membership', type: 'multiselect',
    options: [
      { value: 'basic', label: 'Basic' },
      { value: 'silver', label: 'Silver' },
      { value: 'gold', label: 'Gold' },
      { value: 'platinum', label: 'Platinum' },
    ],
  },
  { key: 'signup_within_days', label: 'Signed up within', group: 'Account', type: 'number', suffix: 'days' },
  { key: 'signup_before_days', label: 'Signed up before', group: 'Account', type: 'number', suffix: 'days' },
  { key: 'handicap_min', label: 'Min handicap', group: 'Profile', type: 'number', placeholder: '-10' },
  { key: 'handicap_max', label: 'Max handicap', group: 'Profile', type: 'number', placeholder: '54' },
];

interface SegmentFilterBuilderProps {
  value: FilterCriteria;
  onChange: (criteria: FilterCriteria) => void;
}

export function SegmentFilterBuilder({ value, onChange }: SegmentFilterBuilderProps) {
  const [activeFilters, setActiveFilters] = useState<string[]>(() =>
    Object.keys(value).filter((k) => value[k as keyof FilterCriteria] !== undefined)
  );

  const [preview, { data: previewData, loading: previewLoading }] = useLazyQuery(PREVIEW_GOLFER_SEGMENT, {
    fetchPolicy: 'network-only',
  });

  const runPreview = useCallback(() => {
    const nonEmpty = Object.fromEntries(
      Object.entries(value).filter(([, v]) => v !== undefined && v !== '' && !(Array.isArray(v) && v.length === 0))
    );
    if (Object.keys(nonEmpty).length > 0) {
      preview({ variables: { filterCriteria: nonEmpty } });
    }
  }, [value, preview]);

  useEffect(() => {
    const timeout = setTimeout(runPreview, 500);
    return () => clearTimeout(timeout);
  }, [runPreview]);

  const addFilter = (key: string) => {
    if (!activeFilters.includes(key)) {
      setActiveFilters([...activeFilters, key]);
    }
  };

  const removeFilter = (key: string) => {
    setActiveFilters(activeFilters.filter((k) => k !== key));
    const newCriteria = { ...value };
    delete newCriteria[key as keyof FilterCriteria];
    onChange(newCriteria);
  };

  const updateFilter = (key: string, filterValue: string | number | string[]) => {
    const newCriteria = { ...value };

    if (key === 'total_spent_min' || key === 'total_spent_max') {
      // Convert dollars to cents
      (newCriteria as Record<string, unknown>)[key] = Math.round(Number(filterValue) * 100);
    } else {
      (newCriteria as Record<string, unknown>)[key] = filterValue;
    }

    onChange(newCriteria);
  };

  const groups = FILTER_OPTIONS.reduce<Record<string, FilterOption[]>>((acc, opt) => {
    if (!acc[opt.group]) acc[opt.group] = [];
    acc[opt.group].push(opt);
    return acc;
  }, {});

  const availableFilters = FILTER_OPTIONS.filter((o) => !activeFilters.includes(o.key));
  const previewResult = previewData?.golferSegmentPreview;

  return (
    <div className="space-y-4">
      {/* Active filters */}
      {activeFilters.length > 0 && (
        <div className="space-y-3">
          {activeFilters.map((key) => {
            const opt = FILTER_OPTIONS.find((o) => o.key === key);
            if (!opt) return null;

            return (
              <div key={key} className="flex items-center gap-3 bg-rough-50 rounded-lg p-3">
                <span className="text-sm font-medium text-rough-700 min-w-[140px]">{opt.label}</span>
                {opt.type === 'number' && (
                  <div className="flex items-center gap-2">
                    <input
                      type="number"
                      value={
                        key === 'total_spent_min' || key === 'total_spent_max'
                          ? ((value[key as keyof FilterCriteria] as number) || 0) / 100
                          : (value[key as keyof FilterCriteria] as number) ?? ''
                      }
                      onChange={(e) => updateFilter(key, e.target.value === '' ? '' : Number(e.target.value))}
                      placeholder={opt.placeholder}
                      className="w-24 rounded-md border-rough-300 text-sm focus:border-fairway-500 focus:ring-fairway-500"
                    />
                    {opt.suffix && <span className="text-sm text-rough-500">{opt.suffix}</span>}
                  </div>
                )}
                {opt.type === 'select' && (
                  <select
                    value={(value[key as keyof FilterCriteria] as string) ?? ''}
                    onChange={(e) => updateFilter(key, e.target.value)}
                    className="rounded-md border-rough-300 text-sm focus:border-fairway-500 focus:ring-fairway-500"
                  >
                    <option value="">Select...</option>
                    {opt.options?.map((o) => (
                      <option key={o.value} value={o.value}>
                        {o.label}
                      </option>
                    ))}
                  </select>
                )}
                {opt.type === 'multiselect' && (
                  <div className="flex flex-wrap gap-2">
                    {opt.options?.map((o) => {
                      const selected = ((value[key as keyof FilterCriteria] as string[]) || []).includes(o.value);
                      return (
                        <button
                          key={o.value}
                          type="button"
                          onClick={() => {
                            const current = ((value[key as keyof FilterCriteria] as string[]) || []);
                            const updated = selected
                              ? current.filter((v) => v !== o.value)
                              : [...current, o.value];
                            updateFilter(key, updated);
                          }}
                          className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                            selected
                              ? 'bg-fairway-600 text-white'
                              : 'bg-white border border-rough-300 text-rough-600 hover:bg-rough-50'
                          }`}
                        >
                          {o.label}
                        </button>
                      );
                    })}
                  </div>
                )}
                <button
                  type="button"
                  onClick={() => removeFilter(key)}
                  className="ml-auto text-rough-400 hover:text-red-500 transition-colors"
                >
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            );
          })}
        </div>
      )}

      {/* Add filter dropdown */}
      {availableFilters.length > 0 && (
        <div>
          <select
            value=""
            onChange={(e) => {
              if (e.target.value) addFilter(e.target.value);
            }}
            className="rounded-md border-rough-300 text-sm text-rough-600 focus:border-fairway-500 focus:ring-fairway-500"
          >
            <option value="">+ Add filter...</option>
            {Object.entries(groups).map(([group, opts]) => {
              const available = opts.filter((o) => !activeFilters.includes(o.key));
              if (available.length === 0) return null;
              return (
                <optgroup key={group} label={group}>
                  {available.map((o) => (
                    <option key={o.key} value={o.key}>
                      {o.label}
                    </option>
                  ))}
                </optgroup>
              );
            })}
          </select>
        </div>
      )}

      {/* Preview */}
      <div className="border-t border-rough-200 pt-4">
        <div className="flex items-center gap-3">
          <span className="text-sm font-medium text-rough-700">Preview:</span>
          {previewLoading ? (
            <span className="text-sm text-rough-500">Evaluating...</span>
          ) : previewResult ? (
            <span className="text-sm font-semibold text-fairway-600">
              {previewResult.count} golfer{previewResult.count !== 1 ? 's' : ''} match
            </span>
          ) : activeFilters.length === 0 ? (
            <span className="text-sm text-rough-400">Add filters to see matching golfers</span>
          ) : null}
        </div>
        {previewResult?.sample?.length > 0 && (
          <div className="mt-2 space-y-1">
            {previewResult.sample.map((user: { id: string; name: string; email: string }) => (
              <div key={user.id} className="text-xs text-rough-500">
                {user.name} ({user.email})
              </div>
            ))}
            {previewResult.count > 5 && (
              <div className="text-xs text-rough-400">...and {previewResult.count - 5} more</div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
