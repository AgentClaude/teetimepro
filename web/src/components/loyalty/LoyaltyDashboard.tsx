import { useState } from "react";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { Card } from "../ui/Card";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type { LoyaltyAccount, LoyaltyProgram, LoyaltyReward } from "../../types/loyalty";

interface LoyaltyDashboardProps {
  loyaltyProgram: LoyaltyProgram | null;
  loyaltyAccount: LoyaltyAccount | null;
  availableRewards: LoyaltyReward[];
  isLoading?: boolean;
  onRedeemReward?: (rewardId: string) => void;
  onViewTransactions?: () => void;
}

export function LoyaltyDashboard({
  loyaltyProgram,
  loyaltyAccount,
  availableRewards,
  isLoading = false,
  onRedeemReward,
  onViewTransactions,
}: LoyaltyDashboardProps) {
  const [selectedReward, setSelectedReward] = useState<string | null>(null);

  const getTierBadgeVariant = (tier: string) => {
    switch (tier) {
      case "platinum":
        return "info";
      case "gold":
        return "warning";
      case "silver":
        return "neutral";
      default:
        return "default";
    }
  };

  const getTierIcon = (tier: string) => {
    switch (tier) {
      case "platinum":
        return "💎";
      case "gold":
        return "🥇";
      case "silver":
        return "🥈";
      default:
        return "🥉";
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-8">
        <LoadingSpinner />
      </div>
    );
  }

  if (!loyaltyProgram) {
    return (
      <Card className="p-8 text-center">
        <div className="text-rough-500">
          <div className="text-4xl mb-2">🎯</div>
          <h3 className="text-lg font-medium mb-2">Loyalty Program Coming Soon</h3>
          <p className="text-sm">
            Your golf course is setting up an exciting loyalty program. Check back soon!
          </p>
        </div>
      </Card>
    );
  }

  if (!loyaltyAccount) {
    return (
      <Card className="p-8 text-center">
        <div className="text-rough-500">
          <div className="text-4xl mb-2">⭐</div>
          <h3 className="text-lg font-medium mb-2">Welcome to {loyaltyProgram.name}!</h3>
          <p className="text-sm mb-4">
            Start earning points by making bookings and purchases at the course.
          </p>
          <p className="text-xs text-rough-400">
            Your loyalty account will be created automatically with your first activity.
          </p>
        </div>
      </Card>
    );
  }

  const progressPercentage = loyaltyAccount.pointsNeededForNextTier > 0
    ? Math.min(
        100,
        ((loyaltyAccount.lifetimePoints - 
          (loyaltyAccount.lifetimePoints - loyaltyAccount.pointsNeededForNextTier)) / 
          loyaltyAccount.pointsNeededForNextTier) * 100
      )
    : 100;

  return (
    <div className="space-y-6">
      {/* Points Balance & Tier Status */}
      <Card className="p-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-rough-900">Your Loyalty Status</h2>
          <Badge variant={getTierBadgeVariant(loyaltyAccount.tier)}>
            {getTierIcon(loyaltyAccount.tier)} {loyaltyAccount.tierName}
          </Badge>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="text-center">
            <div className="text-3xl font-bold text-fairway-600 mb-1">
              {loyaltyAccount.pointsBalance.toLocaleString()}
            </div>
            <div className="text-sm text-rough-600">Available Points</div>
          </div>

          <div className="text-center">
            <div className="text-3xl font-bold text-rough-600 mb-1">
              {loyaltyAccount.lifetimePoints.toLocaleString()}
            </div>
            <div className="text-sm text-rough-600">Lifetime Points</div>
          </div>

          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600 mb-1">
              {loyaltyAccount.pointsNeededForNextTier || "—"}
            </div>
            <div className="text-sm text-rough-600">
              {loyaltyAccount.pointsNeededForNextTier > 0 
                ? "Points to Next Tier" 
                : "Highest Tier Achieved!"}
            </div>
          </div>
        </div>

        {/* Progress Bar for Next Tier */}
        {loyaltyAccount.pointsNeededForNextTier > 0 && (
          <div className="mt-4">
            <div className="flex items-center justify-between text-sm text-rough-600 mb-1">
              <span>Progress to Next Tier</span>
              <span>{Math.round(progressPercentage)}%</span>
            </div>
            <div className="w-full bg-rough-200 rounded-full h-2">
              <div
                className="bg-fairway-500 h-2 rounded-full transition-all duration-300"
                style={{ width: `${progressPercentage}%` }}
              />
            </div>
          </div>
        )}
      </Card>

      {/* Recent Transactions */}
      <Card className="p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-medium text-rough-900">Recent Activity</h3>
          {onViewTransactions && (
            <Button variant="ghost" size="sm" onClick={onViewTransactions}>
              View All
            </Button>
          )}
        </div>

        {loyaltyAccount.recentTransactions && loyaltyAccount.recentTransactions.length > 0 ? (
          <div className="space-y-2">
            {loyaltyAccount.recentTransactions.slice(0, 5).map((transaction) => (
              <div
                key={transaction.id}
                className="flex items-center justify-between py-2 border-b border-rough-100 last:border-0"
              >
                <div className="flex items-center space-x-3">
                  <span className="text-lg">{transaction.transactionIcon}</span>
                  <div>
                    <p className="text-sm font-medium text-rough-900">
                      {transaction.description}
                    </p>
                    <p className="text-xs text-rough-500">
                      {new Date(transaction.createdAt).toLocaleDateString()}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-sm font-medium ${
                    transaction.positive ? "text-green-600" : "text-red-600"
                  }`}>
                    {transaction.pointsDisplay}
                  </p>
                  <p className="text-xs text-rough-500">
                    Balance: {transaction.balanceAfter.toLocaleString()}
                  </p>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-4">
            <p className="text-sm text-rough-500">No recent activity</p>
          </div>
        )}
      </Card>

      {/* Available Rewards */}
      <Card className="p-6">
        <h3 className="text-lg font-medium text-rough-900 mb-4">Available Rewards</h3>

        {availableRewards.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {availableRewards.slice(0, 6).map((reward) => {
              const canAfford = loyaltyAccount.pointsBalance >= reward.pointsCost;
              const canRedeem = reward.canBeRedeemed && canAfford;
              
              return (
                <div
                  key={reward.id}
                  className={`border rounded-lg p-4 ${
                    canAfford ? "border-fairway-200" : "border-rough-200"
                  } ${canAfford ? "bg-fairway-50" : "bg-rough-50"}`}
                >
                  <h4 className="font-medium text-rough-900 mb-1">{reward.name}</h4>
                  <p className="text-sm text-rough-600 mb-2">{reward.discountDisplay}</p>
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium text-fairway-600">
                      {reward.pointsCost.toLocaleString()} points
                    </span>
                    <Button
                      size="sm"
                      disabled={!canRedeem || selectedReward === reward.id}
                      onClick={() => {
                        setSelectedReward(reward.id);
                        onRedeemReward?.(reward.id);
                      }}
                    >
                      {!canAfford ? "Not enough points" : canRedeem ? "Redeem" : "Unavailable"}
                    </Button>
                  </div>
                  {reward.remainingRedemptions !== null && (
                    <p className="text-xs text-rough-500 mt-1">
                      {reward.remainingRedemptions} redemptions left
                    </p>
                  )}
                </div>
              );
            })}
          </div>
        ) : (
          <div className="text-center py-4">
            <p className="text-sm text-rough-500">No rewards available</p>
          </div>
        )}
      </Card>

      {/* Program Info */}
      <Card className="p-6">
        <h3 className="text-lg font-medium text-rough-900 mb-2">{loyaltyProgram.name}</h3>
        {loyaltyProgram.description && (
          <p className="text-sm text-rough-600 mb-3">{loyaltyProgram.description}</p>
        )}
        <p className="text-xs text-rough-500">
          Earn {loyaltyProgram.pointsPerDollar} points for every $1 spent
        </p>
      </Card>
    </div>
  );
}