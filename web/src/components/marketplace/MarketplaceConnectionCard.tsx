import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { Card } from "../ui/Card";
import type { MarketplaceConnection } from "../../types";

interface MarketplaceConnectionCardProps {
  connection: MarketplaceConnection;
  onSync: (connectionId: string) => void;
  onPause: (connectionId: string) => void;
  onResume: (connectionId: string) => void;
  onDisconnect: (connectionId: string) => void;
  onSettings: (connectionId: string) => void;
  syncing?: boolean;
}

const statusVariants: Record<string, "success" | "warning" | "danger" | "default"> = {
  active: "success",
  pending: "warning",
  paused: "default",
  error: "danger",
};

const providerLogos: Record<string, string> = {
  golfnow: "🏌️",
  teeoff: "⛳",
};

export function MarketplaceConnectionCard({
  connection,
  onSync,
  onPause,
  onResume,
  onDisconnect,
  onSettings,
  syncing = false,
}: MarketplaceConnectionCardProps) {
  const formatDate = (dateStr: string | null): string => {
    if (!dateStr) return "Never";
    return new Date(dateStr).toLocaleString();
  };

  return (
    <Card>
      <div className="flex items-start justify-between">
        <div className="flex items-center space-x-3">
          <span className="text-2xl">{providerLogos[connection.provider] || "📡"}</span>
          <div>
            <h3 className="text-lg font-semibold text-rough-900">
              {connection.providerLabel}
            </h3>
            <p className="text-sm text-rough-500">{connection.course.name}</p>
          </div>
        </div>
        <Badge variant={statusVariants[connection.status] || "default"}>
          {connection.status.charAt(0).toUpperCase() + connection.status.slice(1)}
        </Badge>
      </div>

      {connection.lastError && (
        <div className="mt-3 rounded-md bg-red-50 p-3">
          <p className="text-sm text-red-700">{connection.lastError}</p>
        </div>
      )}

      <div className="mt-4 grid grid-cols-3 gap-4">
        <div>
          <p className="text-sm text-rough-500">Active Listings</p>
          <p className="text-xl font-semibold text-rough-900">
            {connection.activeListingsCount}
          </p>
        </div>
        <div>
          <p className="text-sm text-rough-500">Total Listings</p>
          <p className="text-xl font-semibold text-rough-900">
            {connection.totalListingsCount}
          </p>
        </div>
        <div>
          <p className="text-sm text-rough-500">Last Synced</p>
          <p className="text-sm font-medium text-rough-900">
            {formatDate(connection.lastSyncedAt)}
          </p>
        </div>
      </div>

      {connection.effectiveSettings.discount_percent > 0 && (
        <div className="mt-3">
          <Badge variant="warning">
            {connection.effectiveSettings.discount_percent}% marketplace discount
          </Badge>
        </div>
      )}

      <div className="mt-4 flex items-center space-x-2 border-t border-rough-200 pt-4">
        {connection.status === "active" && (
          <>
            <Button
              variant="primary"
              size="sm"
              onClick={() => onSync(connection.id)}
              disabled={syncing}
            >
              {syncing ? "Syncing..." : "Sync Now"}
            </Button>
            <Button
              variant="secondary"
              size="sm"
              onClick={() => onPause(connection.id)}
            >
              Pause
            </Button>
          </>
        )}
        {connection.status === "paused" && (
          <Button
            variant="primary"
            size="sm"
            onClick={() => onResume(connection.id)}
          >
            Resume
          </Button>
        )}
        <Button
          variant="secondary"
          size="sm"
          onClick={() => onSettings(connection.id)}
        >
          Settings
        </Button>
        <Button
          variant="secondary"
          size="sm"
          onClick={() => onDisconnect(connection.id)}
          className="text-red-600 hover:text-red-700"
        >
          Disconnect
        </Button>
      </div>
    </Card>
  );
}
