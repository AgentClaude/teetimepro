import { Card, CardHeader } from "../ui/Card";
import { Badge } from "../ui/Badge";
import type { DistanceMeasurement, GpsFeatureType } from "../../types/gps";
import { GPS_FEATURE_LABELS } from "../../types/gps";

interface DistancePanelProps {
  distances: DistanceMeasurement[];
  holeNumber: number;
  par: number;
}

function distanceColor(yards: number): string {
  if (yards <= 50) return "text-green-600 font-bold";
  if (yards <= 150) return "text-fairway-600 font-semibold";
  if (yards <= 250) return "text-yellow-600";
  return "text-rough-700";
}

function isTarget(featureType: GpsFeatureType): boolean {
  return [
    "GREEN_CENTER",
    "GREEN_FRONT",
    "GREEN_BACK",
    "PIN_POSITION",
    "FAIRWAY_CENTER",
    "LAYUP",
  ].includes(featureType);
}

function isHazard(featureType: GpsFeatureType): boolean {
  return ["BUNKER", "WATER_HAZARD", "OUT_OF_BOUNDS"].includes(featureType);
}

export function DistancePanel({
  distances,
  holeNumber,
  par,
}: DistancePanelProps) {
  const targets = distances.filter((d) => isTarget(d.featureType));
  const hazards = distances.filter((d) => isHazard(d.featureType));
  const other = distances.filter(
    (d) => !isTarget(d.featureType) && !isHazard(d.featureType)
  );

  return (
    <Card>
      <CardHeader
        title={`Hole ${holeNumber} Distances`}
        subtitle={`Par ${par}`}
      />

      {distances.length === 0 ? (
        <p className="text-rough-500 text-sm">
          No distance data available. GPS features may not be mapped for this
          hole.
        </p>
      ) : (
        <div className="space-y-4">
          {targets.length > 0 && (
            <div>
              <h4 className="text-xs font-medium text-rough-500 uppercase tracking-wide mb-2">
                Targets
              </h4>
              <div className="space-y-1">
                {targets.map((d) => (
                  <DistanceRow key={d.featureId} distance={d} />
                ))}
              </div>
            </div>
          )}

          {hazards.length > 0 && (
            <div>
              <h4 className="text-xs font-medium text-rough-500 uppercase tracking-wide mb-2">
                Hazards
              </h4>
              <div className="space-y-1">
                {hazards.map((d) => (
                  <DistanceRow key={d.featureId} distance={d} />
                ))}
              </div>
            </div>
          )}

          {other.length > 0 && (
            <div>
              <h4 className="text-xs font-medium text-rough-500 uppercase tracking-wide mb-2">
                Other
              </h4>
              <div className="space-y-1">
                {other.map((d) => (
                  <DistanceRow key={d.featureId} distance={d} />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </Card>
  );
}

function DistanceRow({ distance }: { distance: DistanceMeasurement }) {
  return (
    <div className="flex items-center justify-between py-2 px-3 rounded-lg bg-rough-50">
      <div className="flex items-center gap-2">
        <Badge
          variant={isHazard(distance.featureType) ? "danger" : "default"}
          size="sm"
        >
          {GPS_FEATURE_LABELS[distance.featureType]}
        </Badge>
        <span className="text-sm text-rough-800">{distance.featureName}</span>
      </div>
      <span className={`text-lg tabular-nums ${distanceColor(distance.distanceYards)}`}>
        {Math.round(distance.distanceYards)} yds
      </span>
    </div>
  );
}
