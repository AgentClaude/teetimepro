import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider, type MockedResponse } from "@apollo/client/testing";
import { NotificationPreferencesCard } from "./NotificationPreferencesCard";
import { 
  GET_NOTIFICATION_PREFERENCES 
} from "../../graphql/queries";
import { 
  UPDATE_NOTIFICATION_PREFERENCES 
} from "../../graphql/mutations";

interface StoryArgs {
  mocks: MockedResponse[];
}

const meta: Meta<typeof NotificationPreferencesCard> = {
  title: "Settings/NotificationPreferencesCard",
  component: NotificationPreferencesCard,
  decorators: [
    (Story, context) => {
      const args = context.args as StoryArgs;
      return (
        <MockedProvider mocks={args.mocks ?? []} addTypename={false}>
          <div className="max-w-4xl p-6 bg-gray-50 min-h-screen">
            <Story />
          </div>
        </MockedProvider>
      );
    },
  ],
};

export default meta;
type Story = StoryObj<typeof NotificationPreferencesCard> & { args: StoryArgs };

const mockNotificationPreferences = {
  id: "1",
  userId: "user_1",
  emailBookingConfirmation: true,
  emailBookingCancellation: true,
  emailBookingReminder: true,
  emailMarketing: false,
  smsBookingConfirmation: true,
  smsBookingCancellation: false,
  smsBookingReminder: true,
  smsMarketing: false,
  pushBookingConfirmation: true,
  pushBookingCancellation: true,
  pushBookingReminder: true,
  pushMarketing: false,
  reminderHoursBefore: 24,
  createdAt: "2024-01-01T00:00:00Z",
  updatedAt: "2024-01-01T00:00:00Z"
};

const mockAllDisabledPreferences = {
  ...mockNotificationPreferences,
  id: "2",
  emailBookingConfirmation: false,
  emailBookingCancellation: false,
  emailBookingReminder: false,
  emailMarketing: false,
  smsBookingConfirmation: false,
  smsBookingCancellation: false,
  smsBookingReminder: false,
  smsMarketing: false,
  pushBookingConfirmation: false,
  pushBookingCancellation: false,
  pushBookingReminder: false,
  pushMarketing: false,
  reminderHoursBefore: 1
};

const mockMarketingEnabledPreferences = {
  ...mockNotificationPreferences,
  id: "3",
  emailMarketing: true,
  smsMarketing: true,
  pushMarketing: true,
  reminderHoursBefore: 48
};

export const Default: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        result: {
          data: {
            notificationPreferences: mockNotificationPreferences
          }
        }
      },
      {
        request: {
          query: UPDATE_NOTIFICATION_PREFERENCES,
          variables: {
            emailBookingConfirmation: false
          }
        },
        result: {
          data: {
            updateNotificationPreferences: {
              notificationPreference: {
                ...mockNotificationPreferences,
                emailBookingConfirmation: false
              },
              errors: []
            }
          }
        }
      }
    ]
  }
};

export const AllDisabled: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        result: {
          data: {
            notificationPreferences: mockAllDisabledPreferences
          }
        }
      }
    ]
  }
};

export const MarketingEnabled: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        result: {
          data: {
            notificationPreferences: mockMarketingEnabledPreferences
          }
        }
      }
    ]
  }
};

export const Loading: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        result: {
          data: {
            notificationPreferences: mockNotificationPreferences
          }
        },
        delay: 3000 // 3 second delay to show loading state
      }
    ]
  }
};

export const ErrorState: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        error: new globalThis.Error("Failed to load notification preferences")
      }
    ]
  }
};

export const NewUser: Story = {
  args: {
    mocks: [
      {
        request: {
          query: GET_NOTIFICATION_PREFERENCES,
        },
        result: {
          data: {
            notificationPreferences: null
          }
        }
      }
    ]
  }
};