import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import { GET_RANGEFINDER_DEVICES } from "../../graphql/gps-queries";
import { REGISTER_RANGEFINDER_DEVICE } from "../../graphql/gps-mutations";
import { Card, CardHeader } from "../ui/Card";
import { Button } from "../ui/Button";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type {
  RangefinderDevice,
  RangefinderDeviceType,
} from "../../types/gps";
import { DEVICE_TYPE_LABELS, DEVICE_STATUS_LABELS } from "../../types/gps";

export function RangefinderDeviceManager() {
  const [showRegisterForm, setShowRegisterForm] = useState(false);
  const { data, loading, error, refetch } = useQuery(GET_RANGEFINDER_DEVICES);

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
          Failed to load devices: {error.message}
        </p>
      </Card>
    );
  }

  const devices: RangefinderDevice[] = data?.rangefinderDevices ?? [];

  return (
    <div className="space-y-4">
      <Card>
        <CardHeader
          title="Rangefinder Devices"
          subtitle={`${devices.length} registered device${devices.length !== 1 ? "s" : ""}`}
          action={
            <Button
              size="sm"
              onClick={() => setShowRegisterForm(!showRegisterForm)}
            >
              {showRegisterForm ? "Cancel" : "Register Device"}
            </Button>
          }
        />

        {showRegisterForm && (
          <RegisterDeviceForm
            onSuccess={() => {
              setShowRegisterForm(false);
              refetch();
            }}
          />
        )}

        {devices.length === 0 ? (
          <p className="text-rough-500 text-sm py-4">
            No rangefinder devices registered yet.
          </p>
        ) : (
          <div className="space-y-3 mt-4">
            {devices.map((device) => (
              <DeviceCard key={device.id} device={device} />
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}

function DeviceCard({ device }: { device: RangefinderDevice }) {
  return (
    <div className="flex items-center justify-between p-4 rounded-lg border border-rough-200">
      <div className="flex items-center gap-3">
        <div
          className={`w-2.5 h-2.5 rounded-full ${device.online ? "bg-green-500" : "bg-rough-300"}`}
        />
        <div>
          <p className="text-sm font-medium text-rough-900">{device.name}</p>
          <p className="text-xs text-rough-500">
            {DEVICE_TYPE_LABELS[device.deviceType]} &middot; {device.deviceId}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-3">
        {device.batteryLevel !== null && (
          <BatteryIndicator level={device.batteryLevel} />
        )}
        <Badge
          variant={device.online ? "success" : "neutral"}
          size="sm"
        >
          {device.online ? "Online" : DEVICE_STATUS_LABELS[device.status]}
        </Badge>
        {device.firmwareVersion && (
          <span className="text-xs text-rough-400">
            v{device.firmwareVersion}
          </span>
        )}
      </div>
    </div>
  );
}

function BatteryIndicator({ level }: { level: number }) {
  const color =
    level > 50 ? "bg-green-500" : level > 20 ? "bg-yellow-500" : "bg-red-500";

  return (
    <div className="flex items-center gap-1">
      <div className="w-6 h-3 rounded border border-rough-300 p-0.5">
        <div
          className={`h-full rounded-sm ${color}`}
          style={{ width: `${Math.min(level, 100)}%` }}
        />
      </div>
      <span className="text-xs text-rough-500">{Math.round(level)}%</span>
    </div>
  );
}

interface RegisterDeviceFormProps {
  onSuccess: () => void;
}

function RegisterDeviceForm({ onSuccess }: RegisterDeviceFormProps) {
  const [deviceId, setDeviceId] = useState("");
  const [name, setName] = useState("");
  const [deviceType, setDeviceType] = useState<RangefinderDeviceType>("CART_GPS");
  const [firmwareVersion, setFirmwareVersion] = useState("");

  const [registerDevice, { loading, error }] = useMutation(
    REGISTER_RANGEFINDER_DEVICE
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const { data } = await registerDevice({
      variables: {
        deviceId,
        name,
        deviceType,
        firmwareVersion: firmwareVersion || null,
      },
    });

    if (data?.registerRangefinderDevice?.errors?.length === 0) {
      onSuccess();
    }
  };

  const deviceTypeOptions: RangefinderDeviceType[] = [
    "HANDHELD_GPS",
    "CART_GPS",
    "WATCH_GPS",
    "LASER_RANGEFINDER",
    "BLUETOOTH_BEACON",
  ];

  return (
    <form
      onSubmit={handleSubmit}
      className="border border-rough-200 rounded-lg p-4 space-y-3 mb-4"
    >
      {error && (
        <p className="text-red-600 text-sm">{error.message}</p>
      )}

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Device ID
          </label>
          <input
            type="text"
            value={deviceId}
            onChange={(e) => setDeviceId(e.target.value)}
            required
            placeholder="e.g. GPS-001"
            className="w-full px-3 py-2 rounded-lg border border-rough-300 text-sm focus:outline-none focus:ring-2 focus:ring-fairway-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Name
          </label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
            placeholder="e.g. Cart GPS #1"
            className="w-full px-3 py-2 rounded-lg border border-rough-300 text-sm focus:outline-none focus:ring-2 focus:ring-fairway-500"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Device Type
          </label>
          <select
            value={deviceType}
            onChange={(e) => setDeviceType(e.target.value as RangefinderDeviceType)}
            className="w-full px-3 py-2 rounded-lg border border-rough-300 text-sm focus:outline-none focus:ring-2 focus:ring-fairway-500"
          >
            {deviceTypeOptions.map((type) => (
              <option key={type} value={type}>
                {DEVICE_TYPE_LABELS[type]}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Firmware Version
          </label>
          <input
            type="text"
            value={firmwareVersion}
            onChange={(e) => setFirmwareVersion(e.target.value)}
            placeholder="e.g. 2.1.0"
            className="w-full px-3 py-2 rounded-lg border border-rough-300 text-sm focus:outline-none focus:ring-2 focus:ring-fairway-500"
          />
        </div>
      </div>

      <div className="flex justify-end">
        <Button type="submit" size="sm" loading={loading}>
          Register Device
        </Button>
      </div>
    </form>
  );
}
