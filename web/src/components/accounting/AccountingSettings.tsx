import { useState } from "react";
import { Card, CardHeader } from "../ui/Card";
import { Button } from "../ui/Button";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import { Badge } from "../ui/Badge";
import { ConnectionStatus } from "./ConnectionStatus";
import { SyncHistory } from "./SyncHistory";
import { AccountMappingConfig } from "./AccountMappingConfig";
import type { AccountingIntegration, AccountingSync } from "../../types";

interface AccountingSettingsProps {
  quickbooksIntegration?: AccountingIntegration;
  xeroIntegration?: AccountingIntegration;
  syncHistory: AccountingSync[];
  loading: boolean;
  onConnect: (provider: "quickbooks" | "xero") => void;
  onDisconnect: (provider: "quickbooks" | "xero") => void;
  onSync: (provider: "quickbooks" | "xero", syncType?: string, force?: boolean) => void;
  onConfigureMapping: (provider: "quickbooks" | "xero", category: string, accountId: string, accountName: string) => void;
}

export function AccountingSettings({
  quickbooksIntegration,
  xeroIntegration,
  syncHistory,
  loading,
  onConnect,
  onDisconnect,
  onSync,
  onConfigureMapping,
}: AccountingSettingsProps) {
  const [activeTab, setActiveTab] = useState<"quickbooks" | "xero" | "history">("quickbooks");

  if (loading) {
    return (
      <div className="flex items-center justify-center p-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader
          title="Accounting Integration"
          subtitle="Connect QuickBooks or Xero to automatically sync your bookings, payments, and financial data"
        />

        {/* Tab Navigation */}
        <div className="border-b border-rough-200 mb-6">
          <nav className="-mb-px flex space-x-8">
            <button
              onClick={() => setActiveTab("quickbooks")}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === "quickbooks"
                  ? "border-primary-500 text-primary-600"
                  : "border-transparent text-rough-500 hover:text-rough-700 hover:border-rough-300"
              }`}
            >
              <div className="flex items-center space-x-2">
                <span>QuickBooks</span>
                {quickbooksIntegration?.connected && (
                  <Badge variant="success" size="sm">
                    Connected
                  </Badge>
                )}
              </div>
            </button>
            <button
              onClick={() => setActiveTab("xero")}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === "xero"
                  ? "border-primary-500 text-primary-600"
                  : "border-transparent text-rough-500 hover:text-rough-700 hover:border-rough-300"
              }`}
            >
              <div className="flex items-center space-x-2">
                <span>Xero</span>
                {xeroIntegration?.connected && (
                  <Badge variant="success" size="sm">
                    Connected
                  </Badge>
                )}
              </div>
            </button>
            <button
              onClick={() => setActiveTab("history")}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === "history"
                  ? "border-primary-500 text-primary-600"
                  : "border-transparent text-rough-500 hover:text-rough-700 hover:border-rough-300"
              }`}
            >
              Sync History
            </button>
          </nav>
        </div>

        {/* Tab Content */}
        {activeTab === "quickbooks" && (
          <div className="space-y-6">
            <ConnectionStatus
              provider="quickbooks"
              integration={quickbooksIntegration}
              onConnect={() => onConnect("quickbooks")}
              onDisconnect={() => onDisconnect("quickbooks")}
              onSync={(syncType, force) => onSync("quickbooks", syncType, force)}
            />
            {quickbooksIntegration?.connected && (
              <AccountMappingConfig
                provider="quickbooks"
                integration={quickbooksIntegration}
                onConfigureMapping={(category, accountId, accountName) =>
                  onConfigureMapping("quickbooks", category, accountId, accountName)
                }
              />
            )}
          </div>
        )}

        {activeTab === "xero" && (
          <div className="space-y-6">
            <ConnectionStatus
              provider="xero"
              integration={xeroIntegration}
              onConnect={() => onConnect("xero")}
              onDisconnect={() => onDisconnect("xero")}
              onSync={(syncType, force) => onSync("xero", syncType, force)}
            />
            {xeroIntegration?.connected && (
              <AccountMappingConfig
                provider="xero"
                integration={xeroIntegration}
                onConfigureMapping={(category, accountId, accountName) =>
                  onConfigureMapping("xero", category, accountId, accountName)
                }
              />
            )}
          </div>
        )}

        {activeTab === "history" && (
          <SyncHistory
            syncHistory={syncHistory}
            onRetrySync={(sync) => {
              // Implementation would retry specific sync
              console.log("Retrying sync:", sync);
            }}
          />
        )}
      </Card>
    </div>
  );
}
