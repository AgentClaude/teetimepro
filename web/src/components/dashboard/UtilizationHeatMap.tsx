import { useMemo } from "react";
import type { UtilizationHeatMapCell, UtilizationHeatMapSummary } from "../../types";

interface UtilizationHeatMapProps {
  cells: UtilizationHeatMapCell[];
  summary: UtilizationHeatMapSummary;
  loading?: boolean;
}

function formatHour(hour: number): string {
  if (hour === 0) return "12 AM";
  if (hour === 12) return "12 PM";
  return hour < 12 ? `${hour} AM` : `${hour - 12} PM`;
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + "T00:00:00");
  return date.toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" });
}

function getHeatColor(utilization: number): string {
  if (utilization === 0) return "bg-gray-100 dark:bg-gray-800";
  if (utilization < 25) return "bg-green-100 dark:bg-green-900/40 text-green-800 dark:text-green-200";
  if (utilization < 50) return "bg-yellow-100 dark:bg-yellow-900/40 text-yellow-800 dark:text-yellow-200";
  if (utilization < 75) return "bg-orange-100 dark:bg-orange-900/40 text-orange-800 dark:text-orange-200";
  return "bg-red-100 dark:bg-red-900/40 text-red-800 dark:text-red-200";
}

function getHeatBorderColor(utilization: number): string {
  if (utilization === 0) return "border-gray-200 dark:border-gray-700";
  if (utilization < 25) return "border-green-200 dark:border-green-800";
  if (utilization < 50) return "border-yellow-200 dark:border-yellow-800";
  if (utilization < 75) return "border-orange-200 dark:border-orange-800";
  return "border-red-200 dark:border-red-800";
}

export function UtilizationHeatMap({ cells, summary, loading }: UtilizationHeatMapProps) {
  const { dates, hours, cellMap } = useMemo(() => {
    const dateSet = new Set<string>();
    const hourSet = new Set<number>();
    const map = new Map<string, UtilizationHeatMapCell>();

    for (const cell of cells) {
      dateSet.add(cell.date);
      hourSet.add(cell.hour);
      map.set(`${cell.date}-${cell.hour}`, cell);
    }

    return {
      dates: Array.from(dateSet).sort(),
      hours: Array.from(hourSet).sort((a, b) => a - b),
      cellMap: map,
    };
  }, [cells]);

  if (loading) {
    return (
      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
        <div className="animate-pulse space-y-4">
          <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-48" />
          <div className="h-64 bg-gray-200 dark:bg-gray-700 rounded" />
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700">
      {/* Header */}
      <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
          Utilization Heat Map
        </h3>
        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
          Occupancy across time slots and dates
        </p>
      </div>

      {/* Summary Stats */}
      <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700 grid grid-cols-2 md:grid-cols-4 gap-4">
        <SummaryCard
          label="Overall Utilization"
          value={`${summary.overallUtilization.toFixed(1)}%`}
        />
        <SummaryCard
          label="Total Bookings"
          value={summary.totalBookedPlayers.toLocaleString()}
          subtitle={`of ${summary.totalCapacity.toLocaleString()} capacity`}
        />
        <SummaryCard
          label="Peak Hour"
          value={summary.peakHour !== null ? formatHour(summary.peakHour) : "—"}
          subtitle={summary.peakHour !== null ? `${summary.peakHourUtilization.toFixed(1)}% utilization` : undefined}
        />
        <SummaryCard
          label="Peak Day"
          value={summary.peakDayOfWeek ?? "—"}
          subtitle={summary.peakDayOfWeek ? `${summary.peakDayUtilization.toFixed(1)}% utilization` : undefined}
        />
      </div>

      {/* Heat Map Grid */}
      <div className="px-6 py-4 overflow-x-auto">
        {cells.length === 0 ? (
          <div className="text-center py-12 text-gray-500 dark:text-gray-400">
            No tee time data available for the selected date range.
          </div>
        ) : (
          <table className="w-full border-collapse">
            <thead>
              <tr>
                <th className="sticky left-0 bg-white dark:bg-gray-900 z-10 text-left text-xs font-medium text-gray-500 dark:text-gray-400 pb-2 pr-3 min-w-[100px]">
                  Date
                </th>
                {hours.map((hour) => (
                  <th
                    key={hour}
                    className="text-center text-xs font-medium text-gray-500 dark:text-gray-400 pb-2 px-1 min-w-[52px]"
                  >
                    {formatHour(hour)}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {dates.map((date) => (
                <tr key={date}>
                  <td className="sticky left-0 bg-white dark:bg-gray-900 z-10 text-xs text-gray-700 dark:text-gray-300 py-1 pr-3 font-medium whitespace-nowrap">
                    {formatDate(date)}
                  </td>
                  {hours.map((hour) => {
                    const cell = cellMap.get(`${date}-${hour}`);
                    const utilization = cell?.utilizationPercentage ?? 0;

                    return (
                      <td key={hour} className="p-0.5">
                        <div
                          className={`rounded border text-center text-xs font-medium py-2 px-1 cursor-default transition-colors ${getHeatColor(utilization)} ${getHeatBorderColor(utilization)}`}
                          title={
                            cell
                              ? `${formatDate(date)} ${formatHour(hour)}\n${cell.bookedPlayers}/${cell.totalCapacity} players (${utilization.toFixed(1)}%)\n${cell.slotCount} slot(s)`
                              : `${formatDate(date)} ${formatHour(hour)}\nNo slots`
                          }
                        >
                          {cell ? `${Math.round(utilization)}%` : "—"}
                        </div>
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Legend */}
      <div className="px-6 py-3 border-t border-gray-200 dark:border-gray-700 flex items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
        <span>Utilization:</span>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 rounded bg-gray-100 dark:bg-gray-800 border border-gray-200 dark:border-gray-700" />
          <span>None</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 rounded bg-green-100 dark:bg-green-900/40 border border-green-200 dark:border-green-800" />
          <span>&lt;25%</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 rounded bg-yellow-100 dark:bg-yellow-900/40 border border-yellow-200 dark:border-yellow-800" />
          <span>25-50%</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 rounded bg-orange-100 dark:bg-orange-900/40 border border-orange-200 dark:border-orange-800" />
          <span>50-75%</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-4 h-4 rounded bg-red-100 dark:bg-red-900/40 border border-red-200 dark:border-red-800" />
          <span>&gt;75%</span>
        </div>
      </div>
    </div>
  );
}

interface SummaryCardProps {
  label: string;
  value: string;
  subtitle?: string;
}

function SummaryCard({ label, value, subtitle }: SummaryCardProps) {
  return (
    <div>
      <p className="text-xs text-gray-500 dark:text-gray-400">{label}</p>
      <p className="text-lg font-semibold text-gray-900 dark:text-gray-100">{value}</p>
      {subtitle && (
        <p className="text-xs text-gray-500 dark:text-gray-400">{subtitle}</p>
      )}
    </div>
  );
}
