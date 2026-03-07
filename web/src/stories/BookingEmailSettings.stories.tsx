import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { BookingEmailSettings } from "../components/settings/BookingEmailSettings";
import { GET_BOOKING_EMAIL_TEMPLATES } from "../graphql/queries";
import { GET_EMAIL_PROVIDERS } from "../graphql/queries";

const meta: Meta<typeof BookingEmailSettings> = {
  title: "Settings/BookingEmailSettings",
  component: BookingEmailSettings,
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
type Story = StoryObj<typeof BookingEmailSettings>;

const mockTemplates = [
  {
    id: "1",
    name: "booking_confirmation",
    subject:
      "⛳ Booking Confirmed — {{course_name}} on {{tee_date}}",
    bodyHtml: `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 24px;">
        <div style="text-align: center; padding: 24px 0;">
          <h1 style="color: #166534; font-size: 24px;">⛳ Booking Confirmed!</h1>
        </div>
        <div style="background: #ffffff; border-radius: 12px; padding: 32px; border: 1px solid #e4e4e7;">
          <p>Hi {{first_name}},</p>
          <p>Your tee time at <strong>{{course_name}}</strong> has been confirmed.</p>
          <table style="width: 100%; margin: 24px 0;">
            <tr><td style="color: #71717a;">Date</td><td style="text-align: right; font-weight: 600;">{{tee_date}}</td></tr>
            <tr><td style="color: #71717a;">Tee Time</td><td style="text-align: right; font-weight: 600;">{{tee_time}}</td></tr>
            <tr><td style="color: #71717a;">Players</td><td style="text-align: right; font-weight: 600;">{{players_count}}</td></tr>
            <tr><td style="color: #71717a;">Confirmation</td><td style="text-align: right; font-family: monospace;">{{confirmation_code}}</td></tr>
          </table>
        </div>
      </div>
    `,
    bodyText: null,
    category: "transactional",
    isActive: true,
    mergeFields: [
      "{{first_name}}",
      "{{course_name}}",
      "{{tee_time}}",
      "{{tee_date}}",
      "{{players_count}}",
      "{{confirmation_code}}",
    ],
    usageCount: 142,
    createdAt: "2026-03-01T10:00:00Z",
    updatedAt: "2026-03-06T10:00:00Z",
    createdBy: { id: "1", fullName: "System" },
  },
  {
    id: "2",
    name: "booking_cancellation",
    subject: "Booking Cancelled — {{course_name}} on {{tee_date}}",
    bodyHtml: `
      <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto; padding: 24px;">
        <div style="text-align: center; padding: 24px 0;">
          <h1 style="color: #dc2626; font-size: 24px;">Booking Cancelled</h1>
        </div>
        <div style="background: #ffffff; border-radius: 12px; padding: 32px; border: 1px solid #e4e4e7;">
          <p>Hi {{first_name}},</p>
          <p>Your booking at <strong>{{course_name}}</strong> has been cancelled.</p>
        </div>
      </div>
    `,
    bodyText: null,
    category: "transactional",
    isActive: true,
    mergeFields: [
      "{{first_name}}",
      "{{course_name}}",
      "{{tee_time}}",
      "{{tee_date}}",
      "{{confirmation_code}}",
      "{{cancellation_reason}}",
    ],
    usageCount: 23,
    createdAt: "2026-03-01T10:00:00Z",
    updatedAt: "2026-03-05T10:00:00Z",
    createdBy: { id: "1", fullName: "System" },
  },
];

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
    maskedApiKey: "SG.a***mnop",
    settings: {},
    createdAt: "2026-03-01T10:00:00Z",
    updatedAt: "2026-03-05T10:00:00Z",
  },
];

export const WithTemplates: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_BOOKING_EMAIL_TEMPLATES },
        result: { data: { bookingEmailTemplates: mockTemplates } },
      },
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: { data: { emailProviders: mockProviders } },
      },
    ],
  },
};

export const NoTemplates: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_BOOKING_EMAIL_TEMPLATES },
        result: { data: { bookingEmailTemplates: [] } },
      },
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: { data: { emailProviders: mockProviders } },
      },
    ],
  },
};

export const NoProvider: Story = {
  args: {
    mocks: [
      {
        request: { query: GET_BOOKING_EMAIL_TEMPLATES },
        result: { data: { bookingEmailTemplates: mockTemplates } },
      },
      {
        request: { query: GET_EMAIL_PROVIDERS },
        result: { data: { emailProviders: [] } },
      },
    ],
  },
};
