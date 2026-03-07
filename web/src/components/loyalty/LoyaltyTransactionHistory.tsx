import { useState } from "react";
import { Badge } from "../ui/Badge";
import { Button } from "../ui/Button";
import { Card } from "../ui/Card";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import type { LoyaltyTransaction } from "../../types/loyalty";

interface LoyaltyTransactionHistoryProps {
  transactions: LoyaltyTransaction[];
  isLoading?: boolean;
  hasNextPage?: boolean;
  onLoadMore?: () => void;
  isLoadingMore?: boolean;
}

export function LoyaltyTransactionHistory({
  transactions,
  isLoading = false,
  hasNextPage = false,
  onLoadMore,
  isLoadingMore = false,
}: LoyaltyTransactionHistoryProps) {
  const [filter, setFilter] = useState<"all" | "earn" | "redeem" | "adjust">("all");

  const getTransactionBadge = (transactionType: string) => {
    switch (transactionType) {
      case "earn":
        return <Badge variant="success">Earned</Badge>;
      case "redeem":
        return <Badge variant="info">Redeemed</Badge>;
      case "adjust":
        return <Badge variant="warning">Adjusted</Badge>;
      case "expire":
        return <Badge variant="danger">Expired</Badge>;
      default:
        return <Badge variant="neutral">{transactionType}</Badge>;
    }
  };

  const getSourceLabel = (transaction: LoyaltyTransaction) => {
    if (!transaction.sourceType || !transaction.sourceId) return null;

    switch (transaction.sourceType) {
      case "Booking":
        return "Booking";
      case "User":
        return "Admin Action";
      case "LoyaltyReward":
        return "Reward Redemption";
      case "LoyaltyProgram":
        return "Tier Update";
      default:
        return transaction.sourceType;
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      return `Today, ${date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
    } else if (diffDays === 1) {
      return `Yesterday, ${date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}`;
    } else if (diffDays < 7) {
      return `${diffDays} days ago`;
    } else {
      return date.toLocaleDateString();
    }
  };

  const filteredTransactions = transactions.filter((transaction) => {
    if (filter === "all") return true;
    return transaction.transactionType === filter;
  });

  const groupedTransactions = filteredTransactions.reduce((groups, transaction) => {
    const date = new Date(transaction.createdAt).toDateString();
    if (!groups[date]) {
      groups[date] = [];
    }
    groups[date].push(transaction);
    return groups;
  }, {} as Record<string, LoyaltyTransaction[]>);

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
      <div>
        <h2 className="text-xl font-semibold text-rough-900 mb-2">Transaction History</h2>
        <p className="text-sm text-rough-600">
          Complete record of all your loyalty point activity
        </p>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center space-x-1 overflow-x-auto">
        <button
          onClick={() => setFilter("all")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "all"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          All ({transactions.length})
        </button>
        <button
          onClick={() => setFilter("earn")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "earn"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          ✅ Earned ({transactions.filter(t => t.transactionType === "earn").length})
        </button>
        <button
          onClick={() => setFilter("redeem")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "redeem"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          🎁 Redeemed ({transactions.filter(t => t.transactionType === "redeem").length})
        </button>
        <button
          onClick={() => setFilter("adjust")}
          className={`px-3 py-1.5 text-sm font-medium rounded-md whitespace-nowrap ${
            filter === "adjust"
              ? "bg-primary-100 text-primary-700"
              : "text-rough-500 hover:text-rough-700"
          }`}
        >
          ⚙️ Adjustments ({transactions.filter(t => t.transactionType === "adjust").length})
        </button>
      </div>

      {/* Transaction List */}
      {filteredTransactions.length > 0 ? (
        <div className="space-y-4">
          {Object.entries(groupedTransactions)
            .sort(([a], [b]) => new Date(b).getTime() - new Date(a).getTime())
            .map(([date, dayTransactions]) => (
              <Card key={date} className="p-4">
                <h3 className="text-sm font-medium text-rough-500 mb-3 border-b border-rough-100 pb-2">
                  {new Date(date).toLocaleDateString('en-US', { 
                    weekday: 'long', 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                  })}
                </h3>
                
                <div className="space-y-3">
                  {dayTransactions.map((transaction) => {
                    const sourceLabel = getSourceLabel(transaction);
                    
                    return (
                      <div
                        key={transaction.id}
                        className="flex items-center justify-between py-3 border-b border-rough-50 last:border-0"
                      >
                        <div className="flex items-center space-x-4">
                          <div className="flex-shrink-0">
                            <div className="w-10 h-10 rounded-full bg-rough-100 flex items-center justify-center text-lg">
                              {transaction.transactionIcon}
                            </div>
                          </div>
                          
                          <div className="flex-1">
                            <div className="flex items-center space-x-2 mb-1">
                              <p className="text-sm font-medium text-rough-900">
                                {transaction.description}
                              </p>
                              {getTransactionBadge(transaction.transactionType)}
                              {sourceLabel && (
                                <Badge variant="neutral" className="text-xs">
                                  {sourceLabel}
                                </Badge>
                              )}
                            </div>
                            
                            <p className="text-xs text-rough-500">
                              {formatDate(transaction.createdAt)}
                            </p>
                          </div>
                        </div>

                        <div className="text-right flex-shrink-0">
                          <p className={`text-lg font-semibold ${
                            transaction.positive 
                              ? "text-green-600" 
                              : "text-red-600"
                          }`}>
                            {transaction.pointsDisplay}
                          </p>
                          <p className="text-xs text-rough-500">
                            Balance: {transaction.balanceAfter.toLocaleString()}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </Card>
            ))}

          {/* Load More Button */}
          {hasNextPage && (
            <div className="text-center">
              <Button
                variant="secondary"
                disabled={isLoadingMore}
                onClick={onLoadMore}
              >
                {isLoadingMore ? (
                  <>
                    <LoadingSpinner className="w-4 h-4 mr-2" />
                    Loading more...
                  </>
                ) : (
                  "Load More Transactions"
                )}
              </Button>
            </div>
          )}
        </div>
      ) : (
        <Card className="p-8 text-center">
          <div className="text-rough-500">
            <div className="text-4xl mb-2">📊</div>
            <h3 className="text-lg font-medium mb-2">
              {filter === "all" ? "No transactions yet" : `No ${filter} transactions found`}
            </h3>
            <p className="text-sm">
              {filter === "all" 
                ? "Start earning points by making bookings and purchases!"
                : `Try selecting a different transaction type to view your activity.`
              }
            </p>
          </div>
        </Card>
      )}
    </div>
  );
}