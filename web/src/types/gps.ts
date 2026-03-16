export type GpsFeatureType =
  | "TEE_BOX"
  | "GREEN_CENTER"
  | "GREEN_FRONT"
  | "GREEN_BACK"
  | "BUNKER"
  | "WATER_HAZARD"
  | "FAIRWAY_CENTER"
  | "DOGLEG"
  | "LAYUP"
  | "PIN_POSITION"
  | "TREE_LINE"
  | "OUT_OF_BOUNDS";

export type RangefinderDeviceType =
  | "HANDHELD_GPS"
  | "CART_GPS"
  | "WATCH_GPS"
  | "LASER_RANGEFINDER"
  | "BLUETOOTH_BEACON";

export type RangefinderDeviceStatus =
  | "ACTIVE"
  | "INACTIVE"
  | "MAINTENANCE"
  | "RETIRED";

export interface CourseGpsFeature {
  id: string;
  name: string;
  featureType: GpsFeatureType;
  latitude: number;
  longitude: number;
  elevationFeet: number | null;
  distanceFromTeeYards: number | null;
  metadata: Record<string, unknown>;
  courseHole: {
    id: string;
    holeNumber: number;
    par: number;
  };
  createdAt: string;
}

export interface RangefinderDevice {
  id: string;
  deviceId: string;
  name: string;
  deviceType: RangefinderDeviceType;
  status: RangefinderDeviceStatus;
  firmwareVersion: string | null;
  batteryLevel: number | null;
  online: boolean;
  lastSeenAt: string | null;
  metadata: Record<string, unknown>;
  createdAt: string;
}

export interface PlayerLocation {
  id: string;
  latitude: number;
  longitude: number;
  accuracyMeters: number | null;
  currentHole: number | null;
  recordedAt: string;
  booking: {
    id: string;
    confirmationCode: string;
    user: {
      fullName: string;
    };
  };
  rangefinderDevice: RangefinderDevice | null;
}

export interface DistanceMeasurement {
  featureId: string;
  featureName: string;
  featureType: GpsFeatureType;
  distanceYards: number;
}

export interface HoleGpsOverview {
  holeNumber: number;
  par: number;
  yardage: number | null;
  features: Array<{
    id: string;
    name: string;
    featureType: string;
    latitude: number;
    longitude: number;
    elevationFeet: number | null;
    distanceFromTeeYards: number | null;
  }>;
  distances?: DistanceMeasurement[];
}

export const GPS_FEATURE_LABELS: Record<GpsFeatureType, string> = {
  TEE_BOX: "Tee Box",
  GREEN_CENTER: "Green (Center)",
  GREEN_FRONT: "Green (Front)",
  GREEN_BACK: "Green (Back)",
  BUNKER: "Bunker",
  WATER_HAZARD: "Water Hazard",
  FAIRWAY_CENTER: "Fairway",
  DOGLEG: "Dogleg",
  LAYUP: "Layup",
  PIN_POSITION: "Pin Position",
  TREE_LINE: "Tree Line",
  OUT_OF_BOUNDS: "Out of Bounds",
};

export const DEVICE_TYPE_LABELS: Record<RangefinderDeviceType, string> = {
  HANDHELD_GPS: "Handheld GPS",
  CART_GPS: "Cart GPS",
  WATCH_GPS: "GPS Watch",
  LASER_RANGEFINDER: "Laser Rangefinder",
  BLUETOOTH_BEACON: "Bluetooth Beacon",
};

export const DEVICE_STATUS_LABELS: Record<RangefinderDeviceStatus, string> = {
  ACTIVE: "Active",
  INACTIVE: "Inactive",
  MAINTENANCE: "Maintenance",
  RETIRED: "Retired",
};
