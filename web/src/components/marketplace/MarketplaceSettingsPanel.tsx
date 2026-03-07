import { useState, useEffect } from "react";
import { Card, CardHeader } from "../ui/Card";
import { Input } from "../ui/Input";
import { Button } from "../ui/Button";
import { Switch } from "../ui/Switch";
import type { MarketplaceConnection, MarketplaceSettings } from "../../types";

interface MarketplaceSettingsPanelProps {
  connection: MarketplaceConnection;
  onSave: (connectionId: string, settings: Partial<MarketplaceSettings>) => void;
  saving?: boolean;
}

export function MarketplaceSettingsPanel({
  connection,
  onSave,
  saving = false,
}: MarketplaceSettingsPanelProps) {
  const [settings, setSettings] = useState<MarketplaceSettings>(connection.effectiveSettings);

  useEffect(() => {
    setSettings(connection.effectiveSettings);
  }, [connection]);

  const handleSave = () => {
    onSave(connection.id, settings);
  };

  const updateSetting = <K extends keyof MarketplaceSettings>(
    key: K,
    value: MarketplaceSettings[K]
  ) => {
    setSettings((prev) => ({ ...prev, [key]: value }));
  };

  return (
    <Card>
      <CardHeader
        title={`${connection.providerLabel} Settings`}
        subtitle={`Configure syndication rules for ${connection.course.name}`}
      />

      <div className="space-y-6">
        {/* Auto Syndication */}
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium text-rough-900">Auto-Syndicate</p>
            <p className="text-sm text-rough-500">
              Automatically list eligible tee times on {connection.providerLabel}
            </p>
          </div>
          <Switch
            checked={settings.auto_syndicate}
            onCheckedChange={(checked: boolean) => updateSetting("auto_syndicate", checked)}
          />
        </div>

        {/* Time Windows */}
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Input
              label="Minimum Advance (hours)"
              type="number"
              min={1}
              max={48}
              value={settings.min_advance_hours.toString()}
              onChange={(e) =>
                updateSetting("min_advance_hours", parseInt(e.target.value) || 4)
              }
            />
            <p className="mt-1 text-xs text-rough-500">
              Don't list tee times less than this many hours away
            </p>
          </div>
          <div>
            <Input
              label="Maximum Advance (days)"
              type="number"
              min={1}
              max={60}
              value={settings.max_advance_days.toString()}
              onChange={(e) =>
                updateSetting("max_advance_days", parseInt(e.target.value) || 14)
              }
            />
            <p className="mt-1 text-xs text-rough-500">
              List tee times up to this many days in advance
            </p>
          </div>
        </div>

        {/* Pricing */}
        <div>
          <Input
            label="Marketplace Discount (%)"
            type="number"
            min={0}
            max={50}
            value={settings.discount_percent.toString()}
            onChange={(e) =>
              updateSetting("discount_percent", parseFloat(e.target.value) || 0)
            }
          />
          <p className="mt-1 text-xs text-rough-500">
            Discount off rack rate for marketplace listings
          </p>
        </div>

        {/* Minimum Spots */}
        <div>
          <Input
            label="Minimum Available Spots"
            type="number"
            min={1}
            max={4}
            value={settings.min_available_spots.toString()}
            onChange={(e) =>
              updateSetting("min_available_spots", parseInt(e.target.value) || 1)
            }
          />
          <p className="mt-1 text-xs text-rough-500">
            Only syndicate tee times with at least this many open spots
          </p>
        </div>

        {/* Save Button */}
        <div className="flex justify-end border-t border-rough-200 pt-4">
          <Button variant="primary" onClick={handleSave} disabled={saving}>
            {saving ? "Saving..." : "Save Settings"}
          </Button>
        </div>
      </div>
    </Card>
  );
}
