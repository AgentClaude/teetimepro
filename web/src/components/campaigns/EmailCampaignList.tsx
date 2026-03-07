import { useQuery, useMutation } from "@apollo/client";
import { GET_EMAIL_CAMPAIGNS } from "../../graphql/queries";
import {
  SEND_EMAIL_CAMPAIGN,
  CANCEL_EMAIL_CAMPAIGN,
} from "../../graphql/mutations";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";
import { CampaignStatusBadge } from "./CampaignStatusBadge";
import { CampaignProgressBar } from "./CampaignProgressBar";

interface EmailCampaign {
  id: string;
  name: string;
  subject: string;
  bodyHtml: string;
  bodyText?: string;
  status: string;
  recipientFilter: string;
  lapsedDays: number;
  isAutomated: boolean;
  recurrenceIntervalDays?: number;
  totalRecipients: number;
  sentCount: number;
  deliveredCount: number;
  openedCount: number;
  clickedCount: number;
  failedCount: number;
  progressPercentage: number;
  openRatePercentage: number;
  clickRatePercentage: number;
  scheduledAt: string | null;
  sentAt: string | null;
  completedAt: string | null;
  createdAt: string;
  createdBy: {
    id: string;
    fullName: string;
  };
}

export function EmailCampaignList() {
  const { data, loading, error } = useQuery(GET_EMAIL_CAMPAIGNS, {
    pollInterval: 10000, // Poll for updates while campaigns are sending
  });

  const [sendCampaign, { loading: sendingCampaign }] = useMutation(
    SEND_EMAIL_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_EMAIL_CAMPAIGNS }],
    }
  );

  const [cancelCampaign, { loading: cancellingCampaign }] = useMutation(
    CANCEL_EMAIL_CAMPAIGN,
    {
      refetchQueries: [{ query: GET_EMAIL_CAMPAIGNS }],
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
        <p className="text-red-600">Error loading email campaigns: {error.message}</p>
      </Card>
    );
  }

  const campaigns: EmailCampaign[] = data?.emailCampaigns ?? [];

  if (campaigns.length === 0) {
    return (
      <Card>
        <div className="py-8 text-center">
          <p className="text-lg font-medium text-rough-900">No email campaigns yet</p>
          <p className="mt-1 text-sm text-rough-500">
            Create your first email campaign to re-engage lapsed golfers.
          </p>
        </div>
      </Card>
    );
  }

  const handleSend = (id: string) => {
    if (window.confirm("Are you sure you want to send this email campaign now?")) {
      sendCampaign({ variables: { id } });
    }
  };

  const handleCancel = (id: string) => {
    if (window.confirm("Are you sure you want to cancel this email campaign?")) {
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
      lapsed: "Lapsed golfers",
      segment: "Custom segment",
    };
    return labels[filter] ?? filter;
  };

  const truncateHtml = (html: string, length: number = 120) => {
    // Simple HTML text extraction for preview
    const text = html.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
    return text.length > length ? `${text.substring(0, length)}...` : text;
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
                {campaign.isAutomated && (
                  <span className="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">
                    🔄 Automated
                  </span>
                )}
              </div>
              <p className="mt-1 text-sm font-medium text-rough-700">
                Subject: {campaign.subject}
              </p>
              <p className="mt-1 text-sm text-rough-600">
                {truncateHtml(campaign.bodyHtml)}
              </p>
              <div className="mt-2 flex gap-4 text-xs text-rough-500">
                <span>📋 {filterLabel(campaign.recipientFilter)}</span>
                <span>📅 {campaign.lapsedDays} days lapsed</span>
                <span>👤 {campaign.createdBy.fullName}</span>
                <span>📅 {formatDate(campaign.createdAt)}</span>
                {campaign.scheduledAt && (
                  <span>⏰ Scheduled: {formatDate(campaign.scheduledAt)}</span>
                )}
                {campaign.recurrenceIntervalDays && (
                  <span>🔄 Every {campaign.recurrenceIntervalDays} days</span>
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
              
              {/* Email-specific stats */}
              {campaign.sentCount > 0 && (
                <div className="mt-2 grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="text-rough-500">Open Rate:</span>
                    <span className="ml-1 font-medium text-rough-900">
                      {campaign.openRatePercentage.toFixed(1)}% 
                    </span>
                    <span className="ml-1 text-rough-500">
                      ({campaign.openedCount}/{campaign.sentCount})
                    </span>
                  </div>
                  <div>
                    <span className="text-rough-500">Click Rate:</span>
                    <span className="ml-1 font-medium text-rough-900">
                      {campaign.clickRatePercentage.toFixed(1)}%
                    </span>
                    <span className="ml-1 text-rough-500">
                      ({campaign.clickedCount}/{campaign.sentCount})
                    </span>
                  </div>
                </div>
              )}
            </div>
          )}
        </Card>
      ))}
    </div>
  );
}