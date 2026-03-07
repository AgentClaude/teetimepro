import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { action } from "@storybook/addon-actions";
import { CreateEmailCampaignModal } from "./CreateEmailCampaignModal";
import { CREATE_EMAIL_CAMPAIGN } from "../../graphql/mutations";

const meta: Meta<typeof CreateEmailCampaignModal> = {
  title: "Campaigns/CreateEmailCampaignModal",
  component: CreateEmailCampaignModal,
  tags: ["autodocs"],
  parameters: {
    layout: "fullscreen",
  },
  args: {
    isOpen: true,
    onClose: action("onClose"),
  },
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof CreateEmailCampaignModal>;

const successMock = {
  request: {
    query: CREATE_EMAIL_CAMPAIGN,
    variables: {
      name: "Spring Re-engagement Campaign",
      subject: "We miss you on the course!",
      bodyHtml: "<p>Hi {{first_name}},</p><p>We've missed seeing you on the course at {{golf_course}}!</p>",
      recipientFilter: "lapsed",
      lapsedDays: 30,
      isAutomated: false,
      recurrenceIntervalDays: null,
      scheduledAt: null,
    },
  },
  result: {
    data: {
      createEmailCampaign: {
        emailCampaign: {
          id: "1",
          name: "Spring Re-engagement Campaign",
          subject: "We miss you on the course!",
          status: "draft",
          createdAt: "2026-03-07T12:00:00Z",
        },
        errors: [],
      },
    },
  },
};

const errorMock = {
  request: {
    query: CREATE_EMAIL_CAMPAIGN,
    variables: {
      name: "",
      subject: "",
      bodyHtml: "",
      recipientFilter: "lapsed",
      lapsedDays: 30,
      isAutomated: false,
      recurrenceIntervalDays: null,
      scheduledAt: null,
    },
  },
  result: {
    data: {
      createEmailCampaign: {
        emailCampaign: null,
        errors: ["Name can't be blank", "Subject can't be blank", "Body HTML can't be blank"],
      },
    },
  },
};

export const Default: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const Closed: Story = {
  args: {
    isOpen: false,
  },
};

export const WithTemplate: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  play: async ({ canvasElement }) => {
    // Simulate clicking "Use Template" button
    const canvas = canvasElement as HTMLElement;
    const useTemplateButton = canvas.querySelector('button[type="button"]') as HTMLButtonElement;
    if (useTemplateButton && useTemplateButton.textContent?.includes("Use Template")) {
      useTemplateButton.click();
    }
  },
};

export const AutomatedCampaign: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  play: async ({ canvasElement }) => {
    // Check the automated checkbox
    const canvas = canvasElement as HTMLElement;
    const automatedCheckbox = canvas.querySelector('input[type="checkbox"]') as HTMLInputElement;
    if (automatedCheckbox) {
      automatedCheckbox.click();
    }
  },
};

export const ScheduledCampaign: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[successMock]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  play: async ({ canvasElement }) => {
    // Select "Schedule for later" radio button
    const canvas = canvasElement as HTMLElement;
    const scheduleRadios = canvas.querySelectorAll('input[name="scheduleType"]') as NodeListOf<HTMLInputElement>;
    const scheduleForLaterRadio = Array.from(scheduleRadios).find(radio => radio.value === "later");
    if (scheduleForLaterRadio) {
      scheduleForLaterRadio.click();
    }
  },
};

export const WithError: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[errorMock]}>
        <div className="min-h-screen bg-gray-50 p-8">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  play: async ({ canvasElement }) => {
    // Try to submit the form without required fields
    const canvas = canvasElement as HTMLElement;
    const submitButton = canvas.querySelector('button[type="submit"]') as HTMLButtonElement;
    if (submitButton) {
      setTimeout(() => submitButton.click(), 100);
    }
  },
};