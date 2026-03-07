import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { EmailProviderSettings } from "../components/campaigns/EmailProviderSettings";
import { GET_EMAIL_PROVIDERS } from "../graphql/queries";

const meta: Meta<typeof EmailProviderSettings> = {
  title: "Campaigns/EmailProviderSettings",
  component: EmailProviderSettings,
  decorators: [
    (Story, context) => (
      <MockedProvider mocks={context.args.mocks ?? []} addTypename={false}>
        <div className="max-w-4xl p-6">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof EmailProviderSettings>;

const mockProviders = [
  {
    id: "1",
    providerType: "sendgrid",
    fromEmail: "noreply@pinevalleygc.com",
    fromName: "Pine Valley Golf Club",
    isActive: true,
    isDefault: true,
    verificationStatus: "verified",
    lastVerifiedAt: "2026-03-05T10:00:00Z",
    maskedApiKey: "SG.a***************mnop",
    settings: {},
    createdAt: "2026-03-01T10:00:00Z",
    updatedAt: "2026-03-05T10:00:00Z",
  },
];

export const WithProviders: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: { data: { emailProviders: mockProviders } },
      },
    ],
  },
};

export const NoProviders: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: { data: { emailProviders: [] } },
      },
    ],
  },
};

export const MultipleProviders: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: {
          data: {
            emailProviders: [
              ...mockProviders,
              {
                id: "2",
                providerType: "mailchimp",
                fromEmail: "marketing@pinevalleygc.com",
                fromName: "Pine Valley Marketing",
                isActive: true,
                isDefault: false,
                verificationStatus: "pending",
                lastVerifiedAt: null,
                maskedApiKey: "mc-a***********wxyz",
                settings: {},
                createdAt: "2026-03-06T10:00:00Z",
                updatedAt: "2026-03-06T10:00:00Z",
              },
            ],
          },
        },
      },
    ],
  },
};
