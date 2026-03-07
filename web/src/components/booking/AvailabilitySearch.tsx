import { useState, useMemo } from "react";
import type { AvailableSlot, AvailabilitySearchResult, TimePreference } from "../../types";

interface AvailabilitySearchProps {
  result: AvailabilitySearchResult | null;
  loading?: boolean;
  onSearch: (params: {
    date: string;
    endDate?: string;
    players: number;
    timePreference?: TimePreference;
    courseId?: string;
  }) => void;
  onSelectSlot?: (slot: AvailableSlot) => void;
  courses?: Array<{ id: string; name: string }>;
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + "T00:00:00");
  return date.toLocaleDateString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
  });
}

function formatCurrency(cents: number | null): string {
  if (cents === null || cents === undefined) return "—";
  return `$${(cents / 100).toFixed(2)}`;
}

function spotsLabel(spots: number): string {
  if (spots === 1) return "1 spot left";
  return `${spots} spots left`;
}

function spotsColor(spots: number, max: number): string {
  const ratio = spots / max;
  if (ratio <= 0.25) return "text-red-600 dark:text-red-400";
  if (ratio <= 0.5) return "text-orange-600 dark:text-orange-400";
  return "text-green-600 dark:text-green-400";
}

export function AvailabilitySearch({
  result,
  loading,
  onSearch,
  onSelectSlot,
  courses,
}: AvailabilitySearchProps) {
  const [date, setDate] = useState(() => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toISOString().split("T")[0];
  });
  const [endDate, setEndDate] = useState("");
  const [players, setPlayers] = useState(2);
  const [timePreference, setTimePreference] = useState<TimePreference | "">("");
  const [courseId, setCourseId] = useState("");

  const handleSearch = () => {
    onSearch({
      date,
      endDate: endDate || undefined,
      players,
      timePreference: (timePreference as TimePreference) || undefined,
      courseId: courseId || undefined,
    });
  };

  // Group slots by date for multi-day display
  const slotsByDate = useMemo(() => {
    if (!result?.slots.length) return new Map<string, AvailableSlot[]>();

    const groups = new Map<string, AvailableSlot[]>();
    for (const slot of result.slots) {
      const existing = groups.get(slot.date) ?? [];
      existing.push(slot);
      groups.set(slot.date, existing);
    }
    return groups;
  }, [result]);

  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700">
      {/* Search Form */}
      <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">
          Check Availability
        </h3>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          {/* Date */}
          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
              Date
            </label>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>

          {/* End Date (optional) */}
          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
              End Date
            </label>
            <input
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              min={date}
              placeholder="Same day"
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>

          {/* Players */}
          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
              Players
            </label>
            <select
              value={players}
              onChange={(e) => setPlayers(Number(e.target.value))}
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              {[1, 2, 3, 4, 5].map((n) => (
                <option key={n} value={n}>
                  {n} {n === 1 ? "Player" : "Players"}
                </option>
              ))}
            </select>
          </div>

          {/* Time Preference */}
          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
              Time
            </label>
            <select
              value={timePreference}
              onChange={(e) => setTimePreference(e.target.value as TimePreference | "")}
              className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Any Time</option>
              <option value="morning">Morning</option>
              <option value="afternoon">Afternoon</option>
              <option value="twilight">Twilight</option>
            </select>
          </div>

          {/* Course */}
          {courses && courses.length > 1 && (
            <div>
              <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1">
                Course
              </label>
              <select
                value={courseId}
                onChange={(e) => setCourseId(e.target.value)}
                className="w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 px-3 py-2 text-sm text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-green-500"
              >
                <option value="">All Courses</option>
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Search Button */}
          <div className="flex items-end">
            <button
              onClick={handleSearch}
              disabled={loading}
              className="w-full rounded-md bg-green-600 hover:bg-green-700 disabled:bg-gray-400 px-4 py-2 text-sm font-medium text-white transition-colors focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
            >
              {loading ? "Searching…" : "Search"}
            </button>
          </div>
        </div>
      </div>

      {/* Loading State */}
      {loading && (
        <div className="px-6 py-12 text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-green-500 border-t-transparent" />
          <p className="mt-3 text-sm text-gray-500 dark:text-gray-400">
            Searching available tee times…
          </p>
        </div>
      )}

      {/* Results */}
      {!loading && result && (
        <div className="px-6 py-4">
          {/* Summary */}
          <div className="mb-4 flex items-center justify-between">
            <p className="text-sm text-gray-600 dark:text-gray-300">
              <span className="font-semibold text-gray-900 dark:text-gray-100">
                {result.totalAvailable}
              </span>{" "}
              tee time{result.totalAvailable !== 1 ? "s" : ""} available
              {result.dateRange.days > 1 &&
                ` across ${result.dateRange.days} days`}
            </p>
          </div>

          {result.slots.length === 0 ? (
            <div className="rounded-lg border border-dashed border-gray-300 dark:border-gray-600 py-12 text-center">
              <svg
                className="mx-auto h-12 w-12 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <p className="mt-3 text-sm font-medium text-gray-900 dark:text-gray-100">
                No tee times available
              </p>
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
                Try adjusting your date, players, or time preference.
              </p>
            </div>
          ) : (
            <div className="space-y-6">
              {Array.from(slotsByDate.entries()).map(([dateKey, slots]) => (
                <div key={dateKey}>
                  {slotsByDate.size > 1 && (
                    <h4 className="mb-3 text-sm font-semibold text-gray-700 dark:text-gray-300 border-b border-gray-100 dark:border-gray-800 pb-2">
                      {formatDate(dateKey)}
                    </h4>
                  )}
                  <div className="grid gap-2">
                    {slots.map((slot) => (
                      <SlotCard
                        key={slot.teeTimeId}
                        slot={slot}
                        players={result.filters.players}
                        onSelect={onSelectSlot}
                      />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

interface SlotCardProps {
  slot: AvailableSlot;
  players: number;
  onSelect?: (slot: AvailableSlot) => void;
}

function SlotCard({ slot, players, onSelect }: SlotCardProps) {
  return (
    <div
      className={`flex items-center justify-between rounded-lg border border-gray-200 dark:border-gray-700 px-4 py-3 transition-colors ${
        onSelect
          ? "cursor-pointer hover:border-green-300 hover:bg-green-50 dark:hover:border-green-700 dark:hover:bg-green-900/20"
          : ""
      }`}
      onClick={() => onSelect?.(slot)}
      role={onSelect ? "button" : undefined}
      tabIndex={onSelect ? 0 : undefined}
      onKeyDown={(e) => {
        if (onSelect && (e.key === "Enter" || e.key === " ")) {
          e.preventDefault();
          onSelect(slot);
        }
      }}
    >
      {/* Time + Course */}
      <div className="flex items-center gap-4">
        <div className="text-center min-w-[64px]">
          <p className="text-lg font-bold text-gray-900 dark:text-gray-100">
            {slot.formattedTime}
          </p>
        </div>
        <div>
          <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
            {slot.courseName}
          </p>
          <p className={`text-xs font-medium ${spotsColor(slot.availableSpots, slot.maxPlayers)}`}>
            {spotsLabel(slot.availableSpots)}
          </p>
        </div>
      </div>

      {/* Pricing */}
      <div className="text-right">
        {slot.hasDynamicPricing && slot.formattedBasePrice !== slot.formattedDynamicPrice && (
          <p className="text-xs text-gray-400 line-through">
            {slot.formattedBasePrice}
          </p>
        )}
        <p className="text-lg font-bold text-gray-900 dark:text-gray-100">
          {slot.formattedDynamicPrice ?? slot.formattedBasePrice ?? "—"}
        </p>
        {players > 1 && slot.totalPriceCents !== null && (
          <p className="text-xs text-gray-500 dark:text-gray-400">
            {formatCurrency(slot.totalPriceCents)} total for {players}
          </p>
        )}
        {slot.hasDynamicPricing && (
          <span className="inline-flex items-center rounded-full bg-blue-50 dark:bg-blue-900/30 px-2 py-0.5 text-xs font-medium text-blue-700 dark:text-blue-300">
            Dynamic pricing
          </span>
        )}
      </div>
    </div>
  );
}
