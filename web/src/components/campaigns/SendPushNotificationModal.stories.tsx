import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { gql } from "@apollo/client";
import { SendPushNotificationModal } from "./SendPushNotificationModal";

const GET_SEGMENTS = gql`
  query GetGolferSegments {
    golferSegments {
      id
      name
      memberCount
    }
  }
`;

const SEND_PROMOTIONAL_PUSH = gql`
  mutation SendPromotionalPush(
    $title: String!
    $body: String!
    $segmentId: ID
  ) {
    sendPromotionalPush(title: $title, body: $body, segmentId: $segmentId) {
      sent
      failed
      errors
    }
  }
`;

const mocks = [
  {
    request: { query: GET_SEGMENTS },
    result: {
      data: {
        golferSegments: [
          { id: "1", name: "Active Members", memberCount: 245 },
          { id: "2", name: "Weekend Golfers", memberCount: 128 },
          { id: "3", name: "New Sign-ups (30d)", memberCount: 42 },
        ],
      },
    },
  },
  {
    request: {
      query: SEND_PROMOTIONAL_PUSH,
      variables: {
        title: "Weekend Special ⛳",
        body: "20% off all tee times this Saturday!",
        segmentId: undefined,
      },
    },
    result: {
      data: {
        sendPromotionalPush: {
          sent: 312,
          failed: 3,
          errors: [],
        },
      },
    },
  },
];

const meta: Meta<typeof SendPushNotificationModal> = {
  title: "Campaigns/SendPushNotificationModal",
  component: SendPushNotificationModal,
  decorators: [
    (Story) => (
      <MockedProvider mocks={mocks} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
  parameters: {
    layout: "centered",
  },
};

export default meta;
type Story = StoryObj<typeof SendPushNotificationModal>;

export const Default: Story = {
  args: {
    isOpen: true,
    onClose: () => console.log("Modal closed"),
  },
};

export const Closed: Story = {
  args: {
    isOpen: false,
    onClose: () => console.log("Modal closed"),
  },
};
