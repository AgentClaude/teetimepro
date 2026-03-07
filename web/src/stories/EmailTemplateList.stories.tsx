import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { EmailTemplateList } from "../components/campaigns/EmailTemplateList";
import { GET_EMAIL_TEMPLATES } from "../graphql/queries";

const meta: Meta<typeof EmailTemplateList> = {
  title: "Campaigns/EmailTemplateList",
  component: EmailTemplateList,
  decorators: [
    (Story, context) => (
      <MockedProvider mocks={context.args.mocks ?? []} addTypename={false}>
        <div className="max-w-6xl p-6">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof EmailTemplateList>;

const mockTemplates = [
  {
    id: "1",
    name: "Welcome Back",
    subject: "We miss you, {{first_name}}!",
    bodyHtml:
      "<h1>Come back to the course!</h1><p>Hi {{first_name}}, it's been a while since your last round at {{organization_name}}.</p>",
    bodyText: null,
    category: "re-engagement",
    isActive: true,
    mergeFields: [
      "{{first_name}}",
      "{{last_name}}",
      "{{organization_name}}",
      "{{unsubscribe_url}}",
    ],
    usageCount: 23,
    createdAt: "2026-02-15T10:00:00Z",
    updatedAt: "2026-03-01T10:00:00Z",
    createdBy: { id: "1", fullName: "Sarah Manager" },
  },
  {
    id: "2",
    name: "Spring Special",
    subject: "🌷 Spring rates now available, {{first_name}}!",
    bodyHtml:
      "<h1>Spring Has Sprung!</h1><p>Hey {{first_name}}, check out our amazing spring rates.</p><p>Book now and save 20%.</p>",
    bodyText: null,
    category: "promotion",
    isActive: true,
    mergeFields: [
      "{{first_name}}",
      "{{full_name}}",
      "{{organization_name}}",
      "{{unsubscribe_url}}",
    ],
    usageCount: 8,
    createdAt: "2026-03-01T10:00:00Z",
    updatedAt: "2026-03-01T10:00:00Z",
    createdBy: { id: "1", fullName: "Sarah Manager" },
  },
  {
    id: "3",
    name: "Monthly Newsletter",
    subject: "{{organization_name}} — March Newsletter",
    bodyHtml:
      "<h1>Monthly Update</h1><p>Dear {{first_name}},</p><p>Here's what's happening this month at the club.</p>",
    bodyText: null,
    category: "newsletter",
    isActive: true,
    mergeFields: [
      "{{first_name}}",
      "{{organization_name}}",
      "{{current_date}}",
      "{{unsubscribe_url}}",
    ],
    usageCount: 45,
    createdAt: "2026-01-10T10:00:00Z",
    updatedAt: "2026-03-05T10:00:00Z",
    createdBy: { id: "2", fullName: "Mike Pro" },
  },
];

export const WithTemplates: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_EMAIL_TEMPLATES, variables: { category: undefined } },
        result: { data: { emailTemplates: mockTemplates } },
      },
    ],
  },
};

export const NoTemplates: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_EMAIL_TEMPLATES, variables: { category: undefined } },
        result: { data: { emailTemplates: [] } },
      },
    ],
  },
};
