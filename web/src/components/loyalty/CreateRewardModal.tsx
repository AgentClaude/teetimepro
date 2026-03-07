import { useState } from "react";
import { Modal } from "../ui/Modal";
import { Button } from "../ui/Button";
import { Input } from "../ui/Input";
import { Switch } from "../ui/Switch";
import type { LoyaltyReward } from "../../types/loyalty";

interface CreateRewardModalProps {
  isOpen: boolean;
  onClose: () => void;
  onCreateReward: (rewardData: CreateRewardData) => Promise<void>;
  isLoading?: boolean;
}

export interface CreateRewardData {
  name: string;
  description?: string;
  pointsCost: number;
  rewardType: "discount_percentage" | "discount_fixed" | "free_round" | "pro_shop_credit";
  discountValue?: number;
  isActive: boolean;
  maxRedemptionsPerUser?: number;
}

const REWARD_TYPES = [
  { value: "discount_percentage", label: "Percentage Discount", icon: "💰", requiresValue: true, valueLabel: "Discount %" },
  { value: "discount_fixed", label: "Fixed Discount", icon: "💵", requiresValue: true, valueLabel: "Discount Amount ($)" },
  { value: "free_round", label: "Free Round", icon: "⛳", requiresValue: false },
  { value: "pro_shop_credit", label: "Pro Shop Credit", icon: "🛍️", requiresValue: true, valueLabel: "Credit Amount ($)" },
] as const;

export function CreateRewardModal({
  isOpen,
  onClose,
  onCreateReward,
  isLoading = false,
}: CreateRewardModalProps) {
  const [formData, setFormData] = useState<CreateRewardData>({
    name: "",
    description: "",
    pointsCost: 100,
    rewardType: "discount_percentage",
    discountValue: 10,
    isActive: true,
    maxRedemptionsPerUser: undefined,
  });
  
  const [errors, setErrors] = useState<Record<string, string>>({});

  const selectedRewardType = REWARD_TYPES.find(type => type.value === formData.rewardType);

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = "Name is required";
    }

    if (!formData.pointsCost || formData.pointsCost <= 0) {
      newErrors.pointsCost = "Points cost must be greater than 0";
    }

    if (selectedRewardType?.requiresValue) {
      if (!formData.discountValue || formData.discountValue <= 0) {
        newErrors.discountValue = `${selectedRewardType.valueLabel} must be greater than 0`;
      }
      
      if (formData.rewardType === "discount_percentage" && formData.discountValue > 100) {
        newErrors.discountValue = "Discount percentage cannot exceed 100%";
      }
    }

    if (formData.maxRedemptionsPerUser && formData.maxRedemptionsPerUser <= 0) {
      newErrors.maxRedemptionsPerUser = "Max redemptions must be greater than 0";
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!validateForm()) return;

    try {
      const submitData = { ...formData };
      
      // Convert discount value to cents for fixed amounts and pro shop credit
      if (formData.rewardType === "discount_fixed" || formData.rewardType === "pro_shop_credit") {
        submitData.discountValue = (formData.discountValue || 0) * 100;
      }
      
      // Remove discountValue for free_round type
      if (formData.rewardType === "free_round") {
        delete submitData.discountValue;
      }

      await onCreateReward(submitData);
      
      // Reset form and close modal
      setFormData({
        name: "",
        description: "",
        pointsCost: 100,
        rewardType: "discount_percentage",
        discountValue: 10,
        isActive: true,
        maxRedemptionsPerUser: undefined,
      });
      setErrors({});
      onClose();
    } catch (error) {
      // Error handling is done by parent component
    }
  };

  const handleInputChange = (field: keyof CreateRewardData, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    
    // Clear error for this field when user starts typing
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: "" }));
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Create New Reward">
      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Info */}
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Reward Name *
            </label>
            <Input
              value={formData.name}
              onChange={(e) => handleInputChange("name", e.target.value)}
              placeholder="e.g., 10% Off Next Round"
              error={errors.name}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Description
            </label>
            <textarea
              className="w-full px-3 py-2 border border-rough-300 rounded-md text-sm"
              rows={3}
              value={formData.description}
              onChange={(e) => handleInputChange("description", e.target.value)}
              placeholder="Optional description of the reward"
            />
          </div>
        </div>

        {/* Reward Type */}
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-3">
            Reward Type *
          </label>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            {REWARD_TYPES.map((type) => (
              <label
                key={type.value}
                className={`relative flex items-center p-3 border rounded-lg cursor-pointer transition-all ${
                  formData.rewardType === type.value
                    ? "border-fairway-300 bg-fairway-50"
                    : "border-rough-200 hover:border-rough-300"
                }`}
              >
                <input
                  type="radio"
                  name="rewardType"
                  value={type.value}
                  checked={formData.rewardType === type.value}
                  onChange={(e) => handleInputChange("rewardType", e.target.value)}
                  className="sr-only"
                />
                <span className="text-lg mr-3">{type.icon}</span>
                <span className="text-sm font-medium text-rough-900">{type.label}</span>
                {formData.rewardType === type.value && (
                  <div className="absolute top-2 right-2 w-2 h-2 bg-fairway-500 rounded-full" />
                )}
              </label>
            ))}
          </div>
        </div>

        {/* Points Cost */}
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Points Cost *
          </label>
          <Input
            type="number"
            min="1"
            value={formData.pointsCost}
            onChange={(e) => handleInputChange("pointsCost", parseInt(e.target.value))}
            placeholder="100"
            error={errors.pointsCost}
          />
        </div>

        {/* Discount Value (conditional) */}
        {selectedRewardType?.requiresValue && (
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              {selectedRewardType.valueLabel} *
            </label>
            <Input
              type="number"
              min="0.01"
              step={formData.rewardType === "discount_percentage" ? "1" : "0.01"}
              max={formData.rewardType === "discount_percentage" ? "100" : undefined}
              value={formData.discountValue || ""}
              onChange={(e) => handleInputChange("discountValue", parseFloat(e.target.value))}
              placeholder={formData.rewardType === "discount_percentage" ? "10" : "20.00"}
              error={errors.discountValue}
            />
            {formData.rewardType === "discount_percentage" && (
              <p className="text-xs text-rough-500 mt-1">Enter percentage (e.g., 10 for 10%)</p>
            )}
            {(formData.rewardType === "discount_fixed" || formData.rewardType === "pro_shop_credit") && (
              <p className="text-xs text-rough-500 mt-1">Enter dollar amount (e.g., 20.00 for $20)</p>
            )}
          </div>
        )}

        {/* Max Redemptions */}
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">
            Max Redemptions per User
          </label>
          <Input
            type="number"
            min="1"
            value={formData.maxRedemptionsPerUser || ""}
            onChange={(e) => handleInputChange("maxRedemptionsPerUser", e.target.value ? parseInt(e.target.value) : undefined)}
            placeholder="Leave empty for unlimited"
            error={errors.maxRedemptionsPerUser}
          />
          <p className="text-xs text-rough-500 mt-1">
            Leave empty to allow unlimited redemptions
          </p>
        </div>

        {/* Active Switch */}
        <div className="flex items-center justify-between">
          <div>
            <label className="text-sm font-medium text-rough-700">Active</label>
            <p className="text-xs text-rough-500">
              Inactive rewards are hidden from customers
            </p>
          </div>
          <Switch
            checked={formData.isActive}
            onChange={(checked) => handleInputChange("isActive", checked)}
          />
        </div>

        {/* Actions */}
        <div className="flex items-center justify-end space-x-3 pt-6 border-t">
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={isLoading}>
            {isLoading ? "Creating..." : "Create Reward"}
          </Button>
        </div>
      </form>
    </Modal>
  );
}