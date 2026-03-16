import { useQuery } from "@apollo/client";
import { GET_COURSE_GPS_FEATURES } from "../../graphql/gps-queries";
import { Card, CardHeader } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type {
  CourseGpsFeature,
  GpsFeatureType,
} from "../../types/gps";
import { GPS_FEATURE_LABELS } from "../../types/gps";

interface GpsFeatureListProps {
  courseId: string;
  holeNumber?: number;
  onFeatureSelect?: (feature: CourseGpsFeature) => void;
}

function featureBadgeVariant(
  featureType: GpsFeatureType
): "success" | "danger" | "warning" | "info" | "default" {
  switch (featureType) {
    case "GREEN_CENTER":
    case "GREEN_FRONT":
    case "GREEN_BACK":
      return "success";
    case "BUNKER":
    case "WATER_HAZARD":
    case "OUT_OF_BOUNDS":
      return "danger";
    case "PIN_POSITION":
      return "warning";
    case "TEE_BOX":
      return "info";
    default:
      return "default";
  }
}

export function GpsFeatureList({
  courseId,
  holeNumber,
  onFeatureSelect,
}: GpsFeatureListProps) {
  const { data, loading, error } = useQuery(GET_COURSE_GPS_FEATURES, {
    variables: { courseId, holeNumber },
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
          Failed to load GPS features: {error.message}
        </p>
      </Card>
    );
  }

  const features: CourseGpsFeature[] = data?.courseGpsFeatures ?? [];

  // Group by hole
  const featuresByHole = features.reduce<
    Record<number, CourseGpsFeature[]>
  >((acc, feature) => {
    const hole = feature.courseHole.holeNumber;
    if (!acc[hole]) acc[hole] = [];
    acc[hole].push(feature);
    return acc;
  }, {});

  const holeNumbers = Object.keys(featuresByHole)
    .map(Number)
    .sort((a, b) => a - b);

  return (
    <Card>
      <CardHeader
        title="GPS Course Features"
        subtitle={`${features.length} features mapped${holeNumber ? ` for hole ${holeNumber}` : ""}`}
      />

      {features.length === 0 ? (
        <p className="text-rough-500 text-sm py-4">
          No GPS features have been mapped for this course yet.
        </p>
      ) : (
        <div className="space-y-6">
          {holeNumbers.map((hole) => (
            <div key={hole}>
              <h4 className="text-sm font-medium text-rough-700 mb-2">
                Hole {hole} (Par {featuresByHole[hole][0].courseHole.par})
              </h4>
              <div className="space-y-2">
                {featuresByHole[hole].map((feature) => (
                  <button
                    key={feature.id}
                    onClick={() => onFeatureSelect?.(feature)}
                    className="w-full flex items-center justify-between p-3 rounded-lg border border-rough-200 hover:bg-rough-50 transition-colors text-left"
                  >
                    <div className="flex items-center gap-3">
                      <Badge
                        variant={featureBadgeVariant(feature.featureType)}
                        size="sm"
                      >
                        {GPS_FEATURE_LABELS[feature.featureType]}
                      </Badge>
                      <span className="text-sm text-rough-900">
                        {feature.name}
                      </span>
                    </div>
                    <div className="flex items-center gap-4 text-xs text-rough-500">
                      {feature.distanceFromTeeYards && (
                        <span>{feature.distanceFromTeeYards} yds from tee</span>
                      )}
                      {feature.elevationFeet && (
                        <span>{feature.elevationFeet} ft elev</span>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </Card>
  );
}
