import { useState } from "react";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { Card } from "../ui/Card";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type { LoyaltyReward, LoyaltyAccount } from "../../types/loyalty";

interface LoyaltyRewardsListProps {
  rewards: LoyaltyReward[];
  loyaltyAccount: LoyaltyAccount | null;
  isLoading?: boolean;
  onRedeemReward?: (rewardId: string) => void;
  showAffordableOnly?: boolean;
  onToggleAffordableFilter?: () => void;
}

export function LoyaltyRewardsList({
  rewards,
  loyaltyAccount,
  isLoading = false,
  onRedeemReward,
  showAffordableOnly = false,
  onToggleAffordableFilter,
}: LoyaltyRewardsListProps) {
  const [redeeming, setRedeeming] = useState<string | null>(null);
  const [filter, setFilter] = useState<"all" | "discount" | "free_round" | "credit">("all");

  const getRewardTypeIcon = (rewardType: string) => {
    switch (rewardType) {
      case "discount_percentage":
      case "discount_fixed":
        return "💰";
      case "free_round":
        return "⛳";
      case "pro_shop_credit":
        return "🛍️";
      default:
        return "🎁";
    }
  };

  const getRewardTypeBadge = (rewardType: string) => {
    switch (rewardType) {
      case "discount_percentage":
        return <Badge variant="success">% Discount</Badge>;
      case "discount_fixed":
        return <Badge variant="success">$ Discount</Badge>;
      case "free_round":
        return <Badge variant="info">Free Round</Badge>;
      case "pro_shop_credit":
        return <Badge variant="warning">Pro Shop</Badge>;
      default:
        return <Badge variant="neutral">{rewardType}</Badge>;
    }
  };

  const handleRedeemReward = async (rewardId: string) => {
    if (!onRedeemReward || redeeming) return;
    
    setRedeeming(rewardId);
    try {
      await onRedeemReward(rewardId);
    } finally {
      setRedeeming(null);
    }
  };

  const filteredRewards = rewards.filter((reward) => {
    // Filter by type
    if (filter !== "all") {
      const typeMap = {
        discount: ["discount_percentage", "discount_fixed"],
        free_round: ["free_round"],
        credit: ["pro_shop_credit"],
      };
      
      if (!typeMap[filter as keyof typeof typeMap]?.includes(reward.rewardType)) {
        return false;
      }
    }

    // Filter by affordability if enabled
    if (showAffordableOnly && loyaltyAccount) {
      return loyaltyAccount.pointsBalance >= reward.pointsCost;
    }

    return true;
  });

  const sortedRewards = filteredRewards.sort((a, b) => a.pointsCost - b.pointsCost);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-8">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-rough-900">Rewards</h2>
          {loyaltyAccount && (
            <p className="text-sm text-rough-600">
              You have {loyaltyAccount.pointsBalance.toLocaleString()} points available
            </p>
          )}
        </div>
        
        {onToggleAffordableFilter && loyaltyAccount && (
          <Button
            variant={showAffordableOnly ? "primary" : "secondary"}
            size="sm"
            onClick={onToggleAffordableFilter}
          >
            {showAffordableOnly ? "Show All" : "Affordable Only"}
          </Button>
        )}
      </div>

      {/* Filters */}
      <div className="flex items-center space-x-1 overflow-x-auto">
        <button
          onClick={() => setFilter("all")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "all"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          All ({rewards.length})
        </button>
        <button
          onClick={() => setFilter("discount")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "discount"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          💰 Discounts ({rewards.filter(r => ["discount_percentage", "discount_fixed"].includes(r.rewardType)).length})
        </button>
        <button
          onClick={() => setFilter("free_round")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "free_round"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          ⛳ Free Rounds ({rewards.filter(r => r.rewardType === "free_round").length})
        </button>
        <button
          onClick={() => setFilter("credit")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "credit"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          🛍️ Credits ({rewards.filter(r => r.rewardType === "pro_shop_credit").length})
        </button>
      </div>

      {/* Rewards Grid */}
      {sortedRewards.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {sortedRewards.map((reward) => {
            const canAfford = loyaltyAccount ? loyaltyAccount.pointsBalance >= reward.pointsCost : false;
            const canRedeem = reward.canBeRedeemed && canAfford;
            const isRedeeming = redeeming === reward.id;

            return (
              <Card
                key={reward.id}
                className={`p-6 transition-all duration-200 ${
                  canAfford
                    ? "border-fairway-200 hover:border-fairway-300"
                    : "border-rough-200"
                } ${canAfford ? "bg-fairway-25" : "bg-white"}`}
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center space-x-2">
                    <span className="text-2xl">{getRewardTypeIcon(reward.rewardType)}</span>
                    {getRewardTypeBadge(reward.rewardType)}
                  </div>
                  {!canAfford && (
                    <Badge variant="neutral" className="text-xs">
                      Need {(reward.pointsCost - (loyaltyAccount?.pointsBalance || 0)).toLocaleString()} more
                    </Badge>
                  )}
                </div>

                <h3 className="text-lg font-semibold text-rough-900 mb-2">
                  {reward.name}
                </h3>

                <div className="mb-3">
                  <p className="text-sm font-medium text-fairway-700 mb-1">
                    {reward.discountDisplay}
                  </p>
                  {reward.description && (
                    <p className="text-sm text-rough-600">{reward.description}</p>
                  )}
                </div>

                <div className="flex items-center justify-between mb-4">
                  <span className="text-lg font-bold text-rough-900">
                    {reward.pointsCost.toLocaleString()}
                  </span>
                  <span className="text-sm text-rough-500">points</span>
                </div>

                {reward.maxRedemptionsPerUser && reward.remainingRedemptions !== null && (
                  <div className="mb-3 text-xs text-rough-500">
                    {reward.remainingRedemptions} of {reward.maxRedemptionsPerUser} redemptions left
                  </div>
                )}

                <Button
                  className="w-full"
                  disabled={!canRedeem || isRedeeming}
                  onClick={() => handleRedeemReward(reward.id)}
                  variant={canAfford ? "primary" : "secondary"}
                >
                  {isRedeeming ? (
                    <>
                      <LoadingSpinner className="w-4 h-4 mr-2" />
                      Redeeming...
                    </>
                  ) : !canAfford ? (
                    "Not enough points"
                  ) : !reward.canBeRedeemed ? (
                    "Unavailable"
                  ) : (
                    "Redeem Now"
                  )}
                </Button>
              </Card>
            );
          })}
        </div>
      ) : (
        <Card className="p-8 text-center">
          <div className="text-rough-500">
            <div className="text-4xl mb-2">🎁</div>
            <h3 className="text-lg font-medium mb-2">
              {filter === "all" ? "No Rewards Available" : `No ${filter} rewards found`}
            </h3>
            <p className="text-sm">
              {filter === "all" 
                ? "Check back soon for new rewards!"
                : "Try adjusting your filters to see more rewards."
              }
            </p>
          </div>
        </Card>
      )}
    </div>
  );
}