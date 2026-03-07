import type { Meta, StoryObj } from "@storybook/react";
import { EmailTemplatePreview } from "../components/campaigns/EmailTemplatePreview";
import { EmailTemplate } from "../types/emailProvider";

const meta: Meta<typeof EmailTemplatePreview> = {
  title: "Campaigns/EmailTemplatePreview",
  component: EmailTemplatePreview,
  decorators: [
    (Story) => (
      <div className="p-6">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof EmailTemplatePreview>;

const sampleTemplate: EmailTemplate = {
  id: "1",
  name: "Welcome Back Campaign",
  subject: "We miss you, {{first_name}}! 🏌️",
  bodyHtml: `
    <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
      <h1 style="color: #1a5632;">Come Back to the Green!</h1>
      <p>Hi <strong>{{first_name}}</strong>,</p>
      <p>It's been a while since your last round at <strong>{{organization_name}}</strong>, 
         and we wanted to let you know we've made some exciting improvements!</p>
      <ul>
        <li>🌿 Newly renovated greens on holes 7-9</li>
        <li>🍽️ Updated clubhouse menu</li>
        <li>⛳ New twilight rates starting at $35</li>
      </ul>
      <p>Book your next tee time today and receive <strong>15% off</strong> your round.</p>
      <a href="#" style="display: inline-block; background: #1a5632; color: white; padding: 12px 24px; 
         border-radius: 6px; text-decoration: none; margin-top: 16px;">Book Now</a>
      <hr style="margin-top: 32px; border: none; border-top: 1px solid #e5e7eb;" />
      <p style="font-size: 12px; color: #6b7280;">
        {{organization_name}} · <a href="{{unsubscribe_url}}">Unsubscribe</a>
      </p>
    </div>
  `,
  bodyText: null,
  category: "re-engagement",
  isActive: true,
  mergeFields: [
    "{{first_name}}",
    "{{last_name}}",
    "{{full_name}}",
    "{{organization_name}}",
    "{{unsubscribe_url}}",
    "{{current_date}}",
  ],
  usageCount: 23,
  createdAt: "2026-02-15T10:00:00Z",
  updatedAt: "2026-03-01T10:00:00Z",
  createdBy: { id: "1", fullName: "Sarah Manager" },
};

export const Default: Story = {
  args: {
    template: sampleTemplate,
    onClose: () => {},
  },
};

export const WithSelectAction: Story = {
  args: {
    template: sampleTemplate,
    onClose: () => {},
    onSelect: () => {},
  },
};
