import { useQuery } from "@apollo/client";
import { GET_PLAYER_LOCATIONS } from "../../graphql/gps-queries";
import { Card, CardHeader } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type { PlayerLocation } from "../../types/gps";

interface PlayerTrackerProps {
  courseId: string;
  holeNumber?: number;
}

export function PlayerTracker({ courseId, holeNumber }: PlayerTrackerProps) {
  const { data, loading, error } = useQuery(GET_PLAYER_LOCATIONS, {
    variables: { courseId, holeNumber },
    pollInterval: 30000, // Refresh every 30 seconds
  });

  if (loading) {
    return (
      <Card>
        <div className="flex items-center justify-center py-8">
          <LoadingSpinner size="lg" />
        </div>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <p className="text-red-600 text-sm">
          Failed to load player locations: {error.message}
        </p>
      </Card>
    );
  }

  const locations: PlayerLocation[] = data?.playerLocations ?? [];

  // Group by hole
  const locationsByHole = locations.reduce<Record<number, PlayerLocation[]>>(
    (acc, loc) => {
      const hole = loc.currentHole ?? 0;
      if (!acc[hole]) acc[hole] = [];
      acc[hole].push(loc);
      return acc;
    },
    {}
  );

  const holeNumbers = Object.keys(locationsByHole)
    .map(Number)
    .sort((a, b) => a - b);

  return (
    <Card>
      <CardHeader
        title="Player Tracker"
        subtitle={`${locations.length} active player${locations.length !== 1 ? "s" : ""} on course`}
      />

      {locations.length === 0 ? (
        <p className="text-rough-500 text-sm py-4">
          No active players with GPS tracking on the course.
        </p>
      ) : (
        <div className="space-y-4">
          {holeNumbers.map((hole) => (
            <div key={hole}>
              <h4 className="text-sm font-medium text-rough-700 mb-2">
                {hole === 0 ? "Unknown Hole" : `Hole ${hole}`}
              </h4>
              <div className="space-y-2">
                {locationsByHole[hole].map((location) => (
                  <PlayerLocationRow
                    key={location.id}
                    location={location}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </Card>
  );
}

function PlayerLocationRow({ location }: { location: PlayerLocation }) {
  const timeSince = getTimeSince(location.recordedAt);

  return (
    <div className="flex items-center justify-between p-3 rounded-lg border border-rough-200">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-fairway-100 flex items-center justify-center">
          <span className="text-xs font-medium text-fairway-700">
            {location.booking.user.fullName
              .split(" ")
              .map((n) => n[0])
              .join("")}
          </span>
        </div>
        <div>
          <p className="text-sm font-medium text-rough-900">
            {location.booking.user.fullName}
          </p>
          <p className="text-xs text-rough-500">
            {location.booking.confirmationCode}
            {location.rangefinderDevice && (
              <> &middot; {location.rangefinderDevice.name}</>
            )}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-2">
        {location.accuracyMeters && (
          <span className="text-xs text-rough-400">
            &plusmn;{Math.round(location.accuracyMeters)}m
          </span>
        )}
        <Badge variant={timeSince.recent ? "success" : "neutral"} size="sm">
          {timeSince.label}
        </Badge>
      </div>
    </div>
  );
}

function getTimeSince(dateStr: string): { label: string; recent: boolean } {
  const seconds = Math.floor(
    (Date.now() - new Date(dateStr).getTime()) / 1000
  );

  if (seconds < 60) return { label: "Just now", recent: true };
  if (seconds < 300)
    return { label: `${Math.floor(seconds / 60)}m ago`, recent: true };
  if (seconds < 3600)
    return { label: `${Math.floor(seconds / 60)}m ago`, recent: false };
  return { label: `${Math.floor(seconds / 3600)}h ago`, recent: false };
}
