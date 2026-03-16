import { useState } from "react";
import { useCourse } from "../../contexts/CourseContext";
import { GpsFeatureList } from "./GpsFeatureList";
import { PlayerTracker } from "./PlayerTracker";
import { RangefinderDeviceManager } from "./RangefinderDeviceManager";
import { DistancePanel } from "./DistancePanel";
import type { CourseGpsFeature, DistanceMeasurement } from "../../types/gps";

type GpsTab = "features" | "tracker" | "devices";

export function GpsDashboard() {
  const { selectedCourse } = useCourse();
  const [activeTab, setActiveTab] = useState<GpsTab>("features");
  const [selectedHole, setSelectedHole] = useState<number | undefined>();
  const [selectedFeature, setSelectedFeature] = useState<CourseGpsFeature | null>(null);
  const [distances] = useState<DistanceMeasurement[]>([]);

  if (!selectedCourse) {
    return (
      <div className="text-center py-12">
        <p className="text-rough-500">Select a course to view GPS data.</p>
      </div>
    );
  }

  const tabs: { key: GpsTab; label: string }[] = [
    { key: "features", label: "Course Map" },
    { key: "tracker", label: "Player Tracker" },
    { key: "devices", label: "Devices" },
  ];

  const holes = Array.from(
    { length: selectedCourse.holes ?? 18 },
    (_, i) => i + 1
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-rough-900">
          GPS & Rangefinder
        </h1>
        <p className="text-rough-500 mt-1">
          Manage course GPS features, track players, and configure rangefinder
          devices.
        </p>
      </div>

      {/* Tab navigation */}
      <div className="border-b border-rough-200">
        <nav className="flex gap-6">
          {tabs.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`pb-3 text-sm font-medium border-b-2 transition-colors ${
                activeTab === tab.key
                  ? "border-fairway-600 text-fairway-600"
                  : "border-transparent text-rough-500 hover:text-rough-700"
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* Hole filter (for features and tracker tabs) */}
      {activeTab !== "devices" && (
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-sm text-rough-600">Hole:</span>
          <button
            onClick={() => setSelectedHole(undefined)}
            className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
              selectedHole === undefined
                ? "bg-fairway-600 text-white"
                : "bg-rough-100 text-rough-600 hover:bg-rough-200"
            }`}
          >
            All
          </button>
          {holes.map((hole) => (
            <button
              key={hole}
              onClick={() => setSelectedHole(hole)}
              className={`px-3 py-1 rounded-full text-xs font-medium transition-colors ${
                selectedHole === hole
                  ? "bg-fairway-600 text-white"
                  : "bg-rough-100 text-rough-600 hover:bg-rough-200"
              }`}
            >
              {hole}
            </button>
          ))}
        </div>
      )}

      {/* Tab content */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          {activeTab === "features" && (
            <GpsFeatureList
              courseId={selectedCourse.id}
              holeNumber={selectedHole}
              onFeatureSelect={setSelectedFeature}
            />
          )}
          {activeTab === "tracker" && (
            <PlayerTracker
              courseId={selectedCourse.id}
              holeNumber={selectedHole}
            />
          )}
          {activeTab === "devices" && <RangefinderDeviceManager />}
        </div>

        {/* Side panel */}
        <div className="space-y-4">
          {selectedFeature && (
            <FeatureDetail
              feature={selectedFeature}
              onClose={() => setSelectedFeature(null)}
            />
          )}
          {distances.length > 0 && selectedHole && (
            <DistancePanel
              distances={distances}
              holeNumber={selectedHole}
              par={selectedFeature?.courseHole.par ?? 4}
            />
          )}
        </div>
      </div>
    </div>
  );
}

function FeatureDetail({
  feature,
  onClose,
}: {
  feature: CourseGpsFeature;
  onClose: () => void;
}) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-rough-200 p-4">
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-semibold text-rough-900">
          Feature Details
        </h3>
        <button
          onClick={onClose}
          className="text-rough-400 hover:text-rough-600 text-sm"
        >
          Close
        </button>
      </div>

      <dl className="space-y-2 text-sm">
        <div>
          <dt className="text-rough-500">Name</dt>
          <dd className="text-rough-900 font-medium">{feature.name}</dd>
        </div>
        <div>
          <dt className="text-rough-500">Hole</dt>
          <dd className="text-rough-900">
            {feature.courseHole.holeNumber} (Par {feature.courseHole.par})
          </dd>
        </div>
        <div>
          <dt className="text-rough-500">Coordinates</dt>
          <dd className="text-rough-900 font-mono text-xs">
            {feature.latitude.toFixed(7)}, {feature.longitude.toFixed(7)}
          </dd>
        </div>
        {feature.elevationFeet && (
          <div>
            <dt className="text-rough-500">Elevation</dt>
            <dd className="text-rough-900">{feature.elevationFeet} ft</dd>
          </div>
        )}
        {feature.distanceFromTeeYards && (
          <div>
            <dt className="text-rough-500">Distance from Tee</dt>
            <dd className="text-rough-900">
              {feature.distanceFromTeeYards} yards
            </dd>
          </div>
        )}
      </dl>
    </div>
  );
}
