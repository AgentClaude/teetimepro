import { useState } from "react";
import { Button } from "../ui/Button";
import { Badge } from "../ui/Badge";
import { Modal } from "../ui/Modal";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type { AccountingIntegration } from "../../types";

interface ConnectionStatusProps {
  provider: "quickbooks" | "xero";
  integration?: AccountingIntegration;
  onConnect: () => void;
  onDisconnect: () => void;
  onSync: (syncType?: string, force?: boolean) => void;
}

export function ConnectionStatus({
  provider,
  integration,
  onConnect,
  onDisconnect,
  onSync,
}: ConnectionStatusProps) {
  const [showDisconnectModal, setShowDisconnectModal] = useState(false);
  const [syncing, setSyncing] = useState(false);

  const isConnected = integration?.connected;
  const hasError = integration?.status === "error";

  const getStatusBadge = () => {
    if (!integration) {
      return <Badge variant="neutral">Not Connected</Badge>;
    }
    
    switch (integration.status) {
      case "connected":
        return <Badge variant="success">Connected</Badge>;
      case "error":
        return <Badge variant="destructive">Error</Badge>;
      case "disconnected":
      default:
        return <Badge variant="neutral">Disconnected</Badge>;
    }
  };

  const getProviderLogo = () => {
    if (provider === "quickbooks") {
      return (
        <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
          <div className="text-blue-600 font-bold text-xl">QB</div>
        </div>
      );
    } else {
      return (
        <div className="w-12 h-12 bg-cyan-100 rounded-lg flex items-center justify-center">
          <div className="text-cyan-600 font-bold text-xl">X</div>
        </div>
      );
    }
  };

  const handleSync = async (syncType?: string, force: boolean = false) => {
    setSyncing(true);
    try {
      await onSync(syncType, force);
    } finally {
      setSyncing(false);
    }
  };

  const handleDisconnect = () => {
    setShowDisconnectModal(false);
    onDisconnect();
  };

  return (
    <>
      <div className="border border-rough-200 rounded-lg p-6">
        <div className="flex items-start justify-between">
          <div className="flex items-center space-x-4">
            {getProviderLogo()}
            <div>
              <h3 className="text-lg font-medium text-rough-900 capitalize">
                {provider}
              </h3>
              <div className="mt-1 flex items-center space-x-2">
                {getStatusBadge()}
              </div>
            </div>
          </div>

          <div className="flex items-center space-x-2">
            {isConnected ? (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleSync()}
                  disabled={syncing}
                >
                  {syncing ? <LoadingSpinner size="sm" /> : "Sync Now"}
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowDisconnectModal(true)}
                >
                  Disconnect
                </Button>
              </>
            ) : (
              <Button onClick={onConnect}>
                Connect to {provider === "quickbooks" ? "QuickBooks" : "Xero"}
              </Button>
            )}
          </div>
        </div>

        {/* Connection Details */}
        {isConnected && integration && (
          <div className="mt-6 space-y-3">
            {integration.companyName && (
              <div>
                <span className="text-sm font-medium text-rough-700">Company:</span>{" "}
                <span className="text-sm text-rough-600">{integration.companyName}</span>
              </div>
            )}
            {integration.connectedAt && (
              <div>
                <span className="text-sm font-medium text-rough-700">Connected:</span>{" "}
                <span className="text-sm text-rough-600">
                  {new Date(integration.connectedAt).toLocaleString()}
                </span>
              </div>
            )}
            {integration.lastSyncAt && (
              <div>
                <span className="text-sm font-medium text-rough-700">Last Sync:</span>{" "}
                <span className="text-sm text-rough-600">
                  {new Date(integration.lastSyncAt).toLocaleString()}
                </span>
              </div>
            )}

            {/* Sync Actions */}
            <div className="mt-4">
              <p className="text-sm font-medium text-rough-700 mb-2">Quick Sync:</p>
              <div className="flex space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleSync("invoice")}
                  disabled={syncing}
                >
                  Sync Invoices
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleSync("payment")}
                  disabled={syncing}
                >
                  Sync Payments
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => handleSync("refund")}
                  disabled={syncing}
                >
                  Sync Refunds
                </Button>
              </div>
            </div>
          </div>
        )}

        {/* Error State */}
        {hasError && integration?.lastErrorMessage && (
          <div className="mt-4 p-3 bg-red-50 border border-red-200 rounded-md">
            <p className="text-sm text-red-800">
              <span className="font-medium">Error:</span> {integration.lastErrorMessage}
            </p>
            {integration.lastErrorAt && (
              <p className="text-xs text-red-600 mt-1">
                Last error: {new Date(integration.lastErrorAt).toLocaleString()}
              </p>
            )}
          </div>
        )}
      </div>

      {/* Disconnect Confirmation Modal */}
      <Modal
        open={showDisconnectModal}
        onClose={() => setShowDisconnectModal(false)}
        title={`Disconnect ${provider === "quickbooks" ? "QuickBooks" : "Xero"}`}
      >
        <div className="space-y-4">
          <p className="text-rough-600">
            Are you sure you want to disconnect from {provider === "quickbooks" ? "QuickBooks" : "Xero"}? 
            This will stop automatic syncing of your financial data.
          </p>
          <div className="flex justify-end space-x-3">
            <Button
              variant="outline"
              onClick={() => setShowDisconnectModal(false)}
            >
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleDisconnect}>
              Disconnect
            </Button>
          </div>
        </div>
      </Modal>
    </>
  );
}