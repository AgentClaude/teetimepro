import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { EmailCampaignList } from "./EmailCampaignList";
import { GET_EMAIL_CAMPAIGNS } from "../../graphql/queries";

const meta: Meta<typeof EmailCampaignList> = {
  title: "Campaigns/EmailCampaignList",
  component: EmailCampaignList,
  tags: ["autodocs"],
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]}>
        <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof EmailCampaignList>;

const mockEmailCampaigns = [
  {
    id: "1",
    name: "Spring Re-engagement Campaign",
    subject: "We miss you on the course, John!",
    bodyHtml: "<p>Hi John,</p><p>We've missed seeing you on the course! Come back for a special 20% discount.</p>",
    bodyText: "Hi John, We've missed seeing you on the course! Come back for a special 20% discount.",
    status: "completed",
    recipientFilter: "lapsed",
    lapsedDays: 30,
    isAutomated: false,
    recurrenceIntervalDays: null,
    totalRecipients: 45,
    sentCount: 45,
    deliveredCount: 42,
    openedCount: 18,
    clickedCount: 8,
    failedCount: 0,
    progressPercentage: 100,
    openRatePercentage: 42.9,
    clickRatePercentage: 17.8,
    scheduledAt: null,
    sentAt: "2026-03-06T10:00:00Z",
    completedAt: "2026-03-06T10:15:00Z",
    createdAt: "2026-03-06T09:45:00Z",
    createdBy: {
      id: "1",
      fullName: "Jane Manager",
    },
  },
  {
    id: "2", 
    name: "Weekend Special Automated",
    subject: "Weekend special just for you, {{first_name}}!",
    bodyHtml: "<p>Hi {{first_name}},</p><p>Special weekend rates available this Saturday and Sunday!</p>",
    bodyText: "Hi {{first_name}}, Special weekend rates available this Saturday and Sunday!",
    status: "sending",
    recipientFilter: "members_only",
    lapsedDays: 60,
    isAutomated: true,
    recurrenceIntervalDays: 14,
    totalRecipients: 124,
    sentCount: 87,
    deliveredCount: 85,
    openedCount: 23,
    clickedCount: 12,
    failedCount: 2,
    progressPercentage: 70,
    openRatePercentage: 27.1,
    clickRatePercentage: 14.1,
    scheduledAt: "2026-03-07T08:00:00Z",
    sentAt: "2026-03-07T08:00:00Z", 
    completedAt: null,
    createdAt: "2026-02-20T14:30:00Z",
    createdBy: {
      id: "2",
      fullName: "Bob Admin",
    },
  },
  {
    id: "3",
    name: "Holiday Tournament Invitation",
    subject: "Join our Memorial Day Tournament!",
    bodyHtml: "<p>Dear {{name}},</p><p>We're excited to invite you to our Memorial Day Tournament!</p>",
    bodyText: "Dear {{name}}, We're excited to invite you to our Memorial Day Tournament!",
    status: "scheduled",
    recipientFilter: "all",
    lapsedDays: 14,
    isAutomated: false,
    recurrenceIntervalDays: null,
    totalRecipients: 0,
    sentCount: 0,
    deliveredCount: 0,
    openedCount: 0,
    clickedCount: 0,
    failedCount: 0,
    progressPercentage: 0,
    openRatePercentage: 0,
    clickRatePercentage: 0,
    scheduledAt: "2026-03-10T12:00:00Z",
    sentAt: null,
    completedAt: null,
    createdAt: "2026-03-07T11:00:00Z",
    createdBy: {
      id: "1", 
      fullName: "Jane Manager",
    },
  },
  {
    id: "4",
    name: "Failed Campaign Test",
    subject: "Test campaign that failed",
    bodyHtml: "<p>This campaign failed to send</p>",
    bodyText: "This campaign failed to send",
    status: "failed",
    recipientFilter: "inactive",
    lapsedDays: 90,
    isAutomated: false,
    recurrenceIntervalDays: null,
    totalRecipients: 12,
    sentCount: 0,
    deliveredCount: 0,
    openedCount: 0,
    clickedCount: 0,
    failedCount: 12,
    progressPercentage: 0,
    openRatePercentage: 0,
    clickRatePercentage: 0,
    scheduledAt: null,
    sentAt: "2026-03-05T15:30:00Z",
    completedAt: null,
    createdAt: "2026-03-05T15:00:00Z",
    createdBy: {
      id: "3",
      fullName: "Test User",
    },
  },
];

const successMock = {
  request: {
    query: GET_EMAIL_CAMPAIGNS,
    variables: { status: undefined },
  },
  result: {
    data: {
      emailCampaigns: mockEmailCampaigns,
    },
  },
};

const loadingMock = {
  request: {
    query: GET_EMAIL_CAMPAIGNS,
    variables: { status: undefined },
  },
  result: {
    data: {
      emailCampaigns: [],
    },
  },
  delay: 30000, // Simulate slow loading
};

const errorMock = {
  request: {
    query: GET_EMAIL_CAMPAIGNS,
    variables: { status: undefined },
  },
  error: new Error("Failed to fetch email campaigns"),
};

const emptyCampaignsMock = {
  request: {
    query: GET_EMAIL_CAMPAIGNS,
    variables: { status: undefined },
  },
  result: {
    data: {
      emailCampaigns: [],
    },
  },
};

export const Default: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]}>
        <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const Loading: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[loadingMock]}>
        <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const ErrorState: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[errorMock]}>
        <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const EmptyState: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[emptyCampaignsMock]}>
        <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};