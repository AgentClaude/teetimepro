import { useState } from "react";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";
import { Modal } from "../ui/Modal";
import type { AccountingIntegration } from "../../types";

interface AccountMappingConfigProps {
  provider: "quickbooks" | "xero";
  integration: AccountingIntegration;
  onConfigureMapping: (category: string, accountId: string, accountName: string) => void;
}

const CATEGORIES = [
  { 
    key: "green_fees", 
    label: "Green Fees", 
    description: "Revenue from tee time bookings",
    icon: "⛳"
  },
  { 
    key: "cart_fees", 
    label: "Cart Fees", 
    description: "Golf cart rental charges",
    icon: "🏌️"
  },
  { 
    key: "merchandise", 
    label: "Merchandise", 
    description: "Pro shop sales",
    icon: "🛍️"
  },
  { 
    key: "food_beverage", 
    label: "Food & Beverage", 
    description: "Restaurant and bar sales",
    icon: "🍽️"
  },
  { 
    key: "lessons", 
    label: "Lessons", 
    description: "Golf instruction fees",
    icon: "🎯"
  },
  { 
    key: "tournaments", 
    label: "Tournaments", 
    description: "Tournament entry fees",
    icon: "🏆"
  },
  { 
    key: "bank_deposits", 
    label: "Bank Deposits", 
    description: "Where payments are deposited",
    icon: "🏦"
  },
];

export function AccountMappingConfig({
  provider,
  integration,
  onConfigureMapping,
}: AccountMappingConfigProps) {
  const [editingCategory, setEditingCategory] = useState<string | null>(null);
  const [accountId, setAccountId] = useState("");
  const [accountName, setAccountName] = useState("");

  const handleEditMapping = (category: string) => {
    const mapping = integration.accountMapping[category];
    setEditingCategory(category);
    setAccountId(mapping?.account_id || "");
    setAccountName(mapping?.account_name || "");
  };

  const handleSaveMapping = () => {
    if (editingCategory && accountId && accountName) {
      onConfigureMapping(editingCategory, accountId, accountName);
      setEditingCategory(null);
      setAccountId("");
      setAccountName("");
    }
  };

  const handleCancelEdit = () => {
    setEditingCategory(null);
    setAccountId("");
    setAccountName("");
  };

  const getAccountHint = () => {
    if (provider === "quickbooks") {
      return "Enter the QuickBooks account ID (e.g., '1', '35', '68')";
    } else {
      return "Enter the Xero account code (e.g., '200', '090', '470')";
    }
  };

  return (
    <>
      <div className="space-y-4">
        <div>
          <h3 className="text-lg font-medium text-rough-900 mb-2">
            Account Mapping
          </h3>
          <p className="text-sm text-rough-600 mb-6">
            Map your tee time categories to {provider === "quickbooks" ? "QuickBooks" : "Xero"} accounts. 
            This ensures transactions are recorded in the correct accounts.
          </p>
        </div>

        <div className="space-y-3">
          {CATEGORIES.map((category) => {
            const mapping = integration.accountMapping[category.key];
            const isMapped = mapping?.account_id && mapping?.account_name;

            return (
              <div
                key={category.key}
                className="border border-rough-200 rounded-lg p-4"
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-3">
                    <span className="text-xl">{category.icon}</span>
                    <div>
                      <h4 className="text-sm font-medium text-rough-900">
                        {category.label}
                      </h4>
                      <p className="text-xs text-rough-500">
                        {category.description}
                      </p>
                      {isMapped && (
                        <p className="text-xs text-primary-600 mt-1">
                          Mapped to: {mapping.account_name} ({mapping.account_id})
                        </p>
                      )}
                    </div>
                  </div>

                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleEditMapping(category.key)}
                  >
                    {isMapped ? "Edit" : "Configure"}
                  </Button>
                </div>
              </div>
            );
          })}
        </div>

        {/* Show warning if important mappings are missing */}
        {(!integration.accountMapping.green_fees ||
          !integration.accountMapping.bank_deposits) && (
          <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
            <div className="flex items-start space-x-2">
              <span className="text-yellow-600 text-lg">⚠️</span>
              <div>
                <h4 className="text-sm font-medium text-yellow-800">
                  Setup Required
                </h4>
                <p className="text-sm text-yellow-700 mt-1">
                  Please configure at least the "Green Fees" and "Bank Deposits" 
                  mappings for basic functionality.
                </p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Edit Mapping Modal */}
      <Modal
        open={!!editingCategory}
        onClose={handleCancelEdit}
        title={`Configure ${CATEGORIES.find(c => c.key === editingCategory)?.label} Mapping`}
      >
        {editingCategory && (
          <div className="space-y-4">
            <p className="text-sm text-rough-600">
              Map "{CATEGORIES.find(c => c.key === editingCategory)?.label}" to a{" "}
              {provider === "quickbooks" ? "QuickBooks" : "Xero"} account.
            </p>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-rough-700 mb-1">
                  Account ID/Code
                </label>
                <Input
                  value={accountId}
                  onChange={(e) => setAccountId(e.target.value)}
                  placeholder={provider === "quickbooks" ? "1" : "200"}
                />
                <p className="text-xs text-rough-500 mt-1">
                  {getAccountHint()}
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-rough-700 mb-1">
                  Account Name
                </label>
                <Input
                  value={accountName}
                  onChange={(e) => setAccountName(e.target.value)}
                  placeholder={provider === "quickbooks" ? "Sales" : "Sales Revenue"}
                />
                <p className="text-xs text-rough-500 mt-1">
                  The descriptive name of the account for reference
                </p>
              </div>
            </div>

            <div className="flex justify-end space-x-3">
              <Button variant="outline" onClick={handleCancelEdit}>
                Cancel
              </Button>
              <Button 
                onClick={handleSaveMapping}
                disabled={!accountId || !accountName}
              >
                Save Mapping
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </>
  );
}