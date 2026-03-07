import { useState } from "react";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import type { AccountingSync } from "../../types";

interface SyncHistoryProps {
  syncHistory: AccountingSync[];
  onRetrySync?: (sync: AccountingSync) => void;
}

export function SyncHistory({ syncHistory, onRetrySync }: SyncHistoryProps) {
  const [filter, setFilter] = useState<"all" | "failed" | "completed">("all");

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "completed":
        return <Badge variant="success" size="sm">Completed</Badge>;
      case "failed":
        return <Badge variant="destructive" size="sm">Failed</Badge>;
      case "pending":
        return <Badge variant="neutral" size="sm">Pending</Badge>;
      case "in_progress":
        return <Badge variant="warning" size="sm">In Progress</Badge>;
      default:
        return <Badge variant="neutral" size="sm">{status}</Badge>;
    }
  };

  const getSyncTypeIcon = (syncType: string) => {
    switch (syncType) {
      case "invoice":
        return "📄";
      case "payment":
        return "💳";
      case "refund":
        return "↩️";
      default:
        return "📊";
    }
  };

  const formatDuration = (duration: number | null) => {
    if (!duration) return "—";
    if (duration < 1) return `${Math.round(duration * 1000)}ms`;
    return `${duration.toFixed(1)}s`;
  };

  const filteredHistory = syncHistory.filter((sync) => {
    if (filter === "all") return true;
    return sync.status === filter;
  });

  if (syncHistory.length === 0) {
    return (
      <div className="text-center py-8">
        <div className="text-rough-500">
          <div className="text-4xl mb-2">📊</div>
          <p className="text-lg font-medium">No sync history yet</p>
          <p className="text-sm">Start syncing your data to see activity here</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Filter Tabs */}
      <div className="flex items-center space-x-1">
        <button
          onClick={() => setFilter("all")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md ${
            filter === "all"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          All ({syncHistory.length})
        </button>
        <button
          onClick={() => setFilter("completed")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md ${
            filter === "completed"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          Completed ({syncHistory.filter(s => s.status === "completed").length})
        </button>
        <button
          onClick={() => setFilter("failed")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md ${
            filter === "failed"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          Failed ({syncHistory.filter(s => s.status === "failed").length})
        </button>
      </div>

      {/* Sync History List */}
      <div className="space-y-2">
        {filteredHistory.map((sync) => (
          <div
            key={sync.id}
            className="border border-rough-200 rounded-lg p-4 hover:bg-rough-50"
          >
            <div className="flex items-start justify-between">
              <div className="flex items-start space-x-3">
                <div className="text-xl mt-0.5">
                  {getSyncTypeIcon(sync.syncType)}
                </div>
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    <h4 className="text-sm font-medium text-rough-900">
                      {sync.syncTypeHumanized}
                    </h4>
                    {getStatusBadge(sync.status)}
                    <span className="text-xs text-rough-500 uppercase">
                      {sync.provider}
                    </span>
                  </div>
                  
                  {/* Syncable Entity Info */}
                  <div className="mt-1 text-sm text-rough-600">
                    {sync.syncable.confirmationCode && (
                      <>
                        Booking #{sync.syncable.confirmationCode}
                        {sync.syncable.user?.fullName && (
                          <> for {sync.syncable.user.fullName}</>
                        )}
                      </>
                    )}
                    {sync.syncable.stripePaymentIntentId && (
                      <>Payment {sync.syncable.stripePaymentIntentId.slice(-6)}</>
                    )}
                  </div>

                  {/* Timestamps */}
                  <div className="mt-2 flex items-center space-x-4 text-xs text-rough-500">
                    <span>
                      Started: {sync.startedAt ? new Date(sync.startedAt).toLocaleString() : "—"}
                    </span>
                    {sync.completedAt && (
                      <span>
                        Completed: {new Date(sync.completedAt).toLocaleString()}
                      </span>
                    )}
                    <span>Duration: {formatDuration(sync.duration)}</span>
                    {sync.retryCount > 0 && (
                      <span>Retries: {sync.retryCount}</span>
                    )}
                  </div>

                  {/* Error Message */}
                  {sync.status === "failed" && sync.errorMessage && (
                    <div className="mt-2 p-2 bg-red-50 border border-red-200 rounded text-sm text-red-800">
                      {sync.errorMessage}
                    </div>
                  )}

                  {/* External ID */}
                  {sync.externalId && (
                    <div className="mt-2 text-xs text-rough-500">
                      External ID: {sync.externalId}
                    </div>
                  )}
                </div>
              </div>

              {/* Actions */}
              <div className="flex items-center space-x-2">
                {sync.status === "failed" && sync.retryable && onRetrySync && (
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onRetrySync(sync)}
                  >
                    Retry
                  </Button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredHistory.length === 0 && filter !== "all" && (
        <div className="text-center py-8">
          <div className="text-rough-500">
            <p className="text-sm">No {filter} syncs found</p>
          </div>
        </div>
      )}
    </div>
  );
}
