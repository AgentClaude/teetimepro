import { Badge } from "../ui/Badge";

type CampaignStatus =
  | "draft"
  | "scheduled"
  | "sending"
  | "completed"
  | "cancelled"
  | "failed";

const statusConfig: Record<
  CampaignStatus,
  { label: string; variant: "default" | "success" | "warning" | "danger" }
> = {
  draft: { label: "Draft", variant: "default" },
  scheduled: { label: "Scheduled", variant: "warning" },
  sending: { label: "Sending", variant: "warning" },
  completed: { label: "Completed", variant: "success" },
  cancelled: { label: "Cancelled", variant: "default" },
  failed: { label: "Failed", variant: "danger" },
};

interface CampaignStatusBadgeProps {
  status: string;
}

export function CampaignStatusBadge({ status }: CampaignStatusBadgeProps) {
  const config = statusConfig[status as CampaignStatus] ?? {
    label: status,
    variant: "default" as const,
  };

  return <Badge variant={config.variant}>{config.label}</Badge>;
}
