import { cn } from "../../lib/utils";

interface CampaignProgressBarProps {
  totalRecipients: number;
  sentCount: number;
  deliveredCount: number;
  failedCount: number;
  progressPercentage: number;
}

export function CampaignProgressBar({
  totalRecipients,
  sentCount,
  deliveredCount,
  failedCount,
  progressPercentage,
}: CampaignProgressBarProps) {
  if (totalRecipients === 0) {
    return (
      <p className="text-sm text-rough-500">No recipients targeted yet</p>
    );
  }

  const deliveredPct =
    totalRecipients > 0 ? (deliveredCount / totalRecipients) * 100 : 0;
  const failedPct =
    totalRecipients > 0 ? (failedCount / totalRecipients) * 100 : 0;

  return (
    <div className="space-y-2">
      <div className="flex justify-between text-sm">
        <span className="text-rough-600">
          {sentCount} of {totalRecipients} sent
        </span>
        <span className="font-medium text-rough-900">
          {progressPercentage}%
        </span>
      </div>
      <div className="h-2 w-full overflow-hidden rounded-full bg-rough-200">
        <div className="flex h-full">
          <div
            className={cn("bg-fairway-500 transition-all duration-500")}
            style={{ width: `${deliveredPct}%` }}
          />
          <div
            className={cn("bg-red-500 transition-all duration-500")}
            style={{ width: `${failedPct}%` }}
          />
        </div>
      </div>
      <div className="flex gap-4 text-xs text-rough-500">
        <span>✅ {deliveredCount} delivered</span>
        {failedCount > 0 && <span>❌ {failedCount} failed</span>}
      </div>
    </div>
  );
}
