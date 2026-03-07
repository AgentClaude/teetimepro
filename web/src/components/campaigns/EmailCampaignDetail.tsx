import { useQuery } from "@apollo/client";
import { GET_EMAIL_CAMPAIGN } from "../../graphql/queries";
import { Card } from "../ui/Card";
import { CampaignStatusBadge } from "./CampaignStatusBadge";
import { CampaignProgressBar } from "./CampaignProgressBar";

interface EmailCampaignDetailProps {
  campaignId: string;
}

interface EmailMessage {
  id: string;
  toEmail: string;
  status: string;
  openedAt: string | null;
  clickedAt: string | null;
  sentAt: string | null;
  deliveredAt: string | null;
  errorMessage: string | null;
  createdAt: string;
  user: {
    id: string;
    fullName: string;
    email: string;
  };
}

export function EmailCampaignDetail({ campaignId }: EmailCampaignDetailProps) {
  const { data, loading, error } = useQuery(GET_EMAIL_CAMPAIGN, {
    variables: { id: campaignId },
    pollInterval: 10000, // Poll for updates
  });

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
        <p className="text-red-600">Error loading campaign: {error.message}</p>
      </Card>
    );
  }

  const campaign = data?.emailCampaign;
  if (!campaign) {
    return (
      <Card>
        <p className="text-rough-600">Campaign not found</p>
      </Card>
    );
  }

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

  const getStatusBadgeColor = (status: string) => {
    const colors: Record<string, string> = {
      pending: "bg-gray-100 text-gray-800",
      sent: "bg-blue-100 text-blue-800",
      delivered: "bg-green-100 text-green-800",
      opened: "bg-purple-100 text-purple-800",
      clicked: "bg-indigo-100 text-indigo-800",
      bounced: "bg-red-100 text-red-800",
      failed: "bg-red-100 text-red-800",
    };
    return colors[status] ?? "bg-gray-100 text-gray-800";
  };

  const getStatusIcon = (status: string) => {
    const icons: Record<string, string> = {
      pending: "⏳",
      sent: "📤",
      delivered: "✅",
      opened: "👀",
      clicked: "🔗",
      bounced: "❌",
      failed: "💥",
    };
    return icons[status] ?? "❓";
  };

  const messages: EmailMessage[] = campaign.emailMessages ?? [];

  return (
    <div className="space-y-6">
      {/* Campaign Header */}
      <Card>
        <div className="flex items-start justify-between">
          <div>
            <div className="flex items-center gap-3">
              <h1 className="text-2xl font-bold text-rough-900">
                {campaign.name}
              </h1>
              <CampaignStatusBadge status={campaign.status} />
              {campaign.isAutomated && (
                <span className="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">
                  🔄 Automated
                </span>
              )}
            </div>
            <p className="mt-1 text-lg text-rough-700">
              Subject: {campaign.subject}
            </p>
            <div className="mt-2 grid grid-cols-2 gap-4 text-sm text-rough-600">
              <div>📋 {filterLabel(campaign.recipientFilter)}</div>
              <div>👤 Created by {campaign.createdBy.fullName}</div>
              <div>📅 Created {formatDate(campaign.createdAt)}</div>
              {campaign.scheduledAt && (
                <div>⏰ Scheduled for {formatDate(campaign.scheduledAt)}</div>
              )}
              {campaign.sentAt && (
                <div>📤 Sent {formatDate(campaign.sentAt)}</div>
              )}
              {campaign.completedAt && (
                <div>✅ Completed {formatDate(campaign.completedAt)}</div>
              )}
            </div>
            
            {campaign.lapsedDays && (
              <div className="mt-2 text-sm text-rough-600">
                📊 Targeting golfers with no bookings in {campaign.lapsedDays} days
              </div>
            )}
            
            {campaign.recurrenceIntervalDays && (
              <div className="mt-2 text-sm text-rough-600">
                🔄 Recurs every {campaign.recurrenceIntervalDays} days
              </div>
            )}
          </div>
        </div>

        {/* Campaign Stats */}
        {(campaign.status === "sending" || campaign.status === "completed") && (
          <div className="mt-6 border-t border-rough-200 pt-6">
            <CampaignProgressBar
              totalRecipients={campaign.totalRecipients}
              sentCount={campaign.sentCount}
              deliveredCount={campaign.deliveredCount}
              failedCount={campaign.failedCount}
              progressPercentage={campaign.progressPercentage}
            />

            <div className="mt-4 grid grid-cols-4 gap-4">
              <div className="text-center">
                <div className="text-2xl font-bold text-blue-600">
                  {campaign.sentCount}
                </div>
                <div className="text-sm text-rough-600">Sent</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-green-600">
                  {campaign.deliveredCount}
                </div>
                <div className="text-sm text-rough-600">Delivered</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-purple-600">
                  {campaign.openedCount}
                </div>
                <div className="text-sm text-rough-600">
                  Opened ({campaign.openRatePercentage.toFixed(1)}%)
                </div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold text-indigo-600">
                  {campaign.clickedCount}
                </div>
                <div className="text-sm text-rough-600">
                  Clicked ({campaign.clickRatePercentage.toFixed(1)}%)
                </div>
              </div>
            </div>
          </div>
        )}
      </Card>

      {/* Email Content Preview */}
      <Card>
        <h2 className="text-lg font-semibold text-rough-900">Email Content</h2>
        <div className="mt-4 border border-rough-200 rounded-lg p-4 bg-white max-h-96 overflow-y-auto">
          <div dangerouslySetInnerHTML={{ __html: campaign.bodyHtml }} />
        </div>
        {campaign.bodyText && (
          <details className="mt-4">
            <summary className="text-sm font-medium text-rough-700 cursor-pointer">
              Text Version
            </summary>
            <div className="mt-2 border border-rough-200 rounded-lg p-4 bg-rough-50 font-mono text-sm whitespace-pre-wrap">
              {campaign.bodyText}
            </div>
          </details>
        )}
      </Card>

      {/* Message List */}
      {messages.length > 0 && (
        <Card>
          <h2 className="text-lg font-semibold text-rough-900">
            Email Messages ({messages.length})
          </h2>
          <div className="mt-4 overflow-x-auto">
            <table className="min-w-full divide-y divide-rough-200">
              <thead className="bg-rough-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                    Recipient
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                    Sent
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                    Opened
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">
                    Clicked
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-rough-200 bg-white">
                {messages.map((message) => (
                  <tr key={message.id}>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-rough-900">
                      <div>
                        <div className="font-medium">{message.user.fullName}</div>
                        <div className="text-rough-500">{message.toEmail}</div>
                      </div>
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm">
                      <span
                        className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${getStatusBadgeColor(
                          message.status
                        )}`}
                      >
                        {getStatusIcon(message.status)} {message.status}
                      </span>
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-rough-500">
                      {formatDate(message.sentAt)}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-rough-500">
                      {formatDate(message.openedAt)}
                    </td>
                    <td className="whitespace-nowrap px-6 py-4 text-sm text-rough-500">
                      {formatDate(message.clickedAt)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}
    </div>
  );
}