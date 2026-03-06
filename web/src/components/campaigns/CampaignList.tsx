import { useQuery, useMutation } from "@apollo/client";
import { GET_SMS_CAMPAIGNS } from "../../graphql/queries";
import {
  SEND_SMS_CAMPAIGN,
  CANCEL_SMS_CAMPAIGN,
} from "../../graphql/mutations";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { CampaignStatusBadge } from "./CampaignStatusBadge";
import { CampaignProgressBar } from "./CampaignProgressBar";

interface SmsCampaign {
  id: string;
  name: string;
  messageBody: string;
  status: string;
  recipientFilter: string;
  totalRecipients: number;
  sentCount: number;
  deliveredCount: number;
  failedCount: number;
  progressPercentage: number;
  scheduledAt: string | null;
  sentAt: string | null;
  completedAt: string | null;
  createdAt: string;
  createdBy: {
    id: string;
    fullName: string;
  };
}

export function CampaignList() {
  const { data, loading, error } = useQuery(GET_SMS_CAMPAIGNS, {
    pollInterval: 10000, // Poll for updates while campaigns are sending
  });

  const [sendCampaign, { loading: sendingCampaign }] = useMutation(
    SEND_SMS_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_SMS_CAMPAIGNS }],
    }
  );

  const [cancelCampaign, { loading: cancellingCampaign }] = useMutation(
    CANCEL_SMS_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_SMS_CAMPAIGNS }],
    }
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-fairway-500 border-t-transparent" />
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <p className="text-red-600">Error loading campaigns: {error.message}</p>
      </Card>
    );
  }

  const campaigns: SmsCampaign[] = data?.smsCampaigns ?? [];

  if (campaigns.length === 0) {
    return (
      <Card>
        <div className="py-8 text-center">
          <p className="text-lg font-medium text-rough-900">No campaigns yet</p>
          <p className="mt-1 text-sm text-rough-500">
            Create your first SMS campaign to reach your golfers.
          </p>
        </div>
      </Card>
    );
  }

  const handleSend = (id: string) => {
    if (window.confirm("Are you sure you want to send this campaign now?")) {
      sendCampaign({ variables: { id } });
    }
  };

  const handleCancel = (id: string) => {
    if (window.confirm("Are you sure you want to cancel this campaign?")) {
      cancelCampaign({ variables: { id } });
    }
  };

  const formatDate = (dateStr: string | null) => {
    if (!dateStr) return "—";
    return new Date(dateStr).toLocaleDateString("en-US", {
      month: "short",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "2-digit",
    });
  };

  const filterLabel = (filter: string) => {
    const labels: Record<string, string> = {
      all: "All users",
      members_only: "Members only",
      recent_bookers: "Recent bookers",
      inactive: "Inactive users",
      custom: "Custom filter",
    };
    return labels[filter] ?? filter;
  };

  return (
    <div className="space-y-4">
      {campaigns.map((campaign) => (
        <Card key={campaign.id}>
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <div className="flex items-center gap-3">
                <h3 className="text-lg font-semibold text-rough-900">
                  {campaign.name}
                </h3>
                <CampaignStatusBadge status={campaign.status} />
              </div>
              <p className="mt-1 text-sm text-rough-600">
                {campaign.messageBody.length > 120
                  ? `${campaign.messageBody.substring(0, 120)}...`
                  : campaign.messageBody}
              </p>
              <div className="mt-2 flex gap-4 text-xs text-rough-500">
                <span>📋 {filterLabel(campaign.recipientFilter)}</span>
                <span>👤 {campaign.createdBy.fullName}</span>
                <span>📅 {formatDate(campaign.createdAt)}</span>
                {campaign.scheduledAt && (
                  <span>⏰ Scheduled: {formatDate(campaign.scheduledAt)}</span>
                )}
              </div>
            </div>

            <div className="ml-4 flex gap-2">
              {(campaign.status === "draft" ||
                campaign.status === "scheduled") && (
                <Button
                  size="sm"
                  variant="primary"
                  onClick={() => handleSend(campaign.id)}
                  loading={sendingCampaign}
                >
                  Send Now
                </Button>
              )}
              {["draft", "scheduled", "sending"].includes(campaign.status) && (
                <Button
                  size="sm"
                  variant="danger"
                  onClick={() => handleCancel(campaign.id)}
                  loading={cancellingCampaign}
                >
                  Cancel
                </Button>
              )}
            </div>
          </div>

          {(campaign.status === "sending" ||
            campaign.status === "completed") && (
            <div className="mt-4 border-t border-rough-200 pt-4">
              <CampaignProgressBar
                totalRecipients={campaign.totalRecipients}
                sentCount={campaign.sentCount}
                deliveredCount={campaign.deliveredCount}
                failedCount={campaign.failedCount}
                progressPercentage={campaign.progressPercentage}
              />
            </div>
          )}
        </Card>
      ))}
    </div>
  );
}
