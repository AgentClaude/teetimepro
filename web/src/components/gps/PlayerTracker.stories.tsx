import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { PlayerTracker } from "./PlayerTracker";
import { GET_PLAYER_LOCATIONS } from "../../graphql/gps-queries";

const meta: Meta<typeof PlayerTracker> = {
  title: "GPS/PlayerTracker",
  component: PlayerTracker,
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof PlayerTracker>;

const mockLocations = [
  {
    id: "pl-1",
    latitude: 33.449,
    longitude: -112.074,
    accuracyMeters: 3.5,
    currentHole: 3,
    recordedAt: new Date(Date.now() - 30 * 1000).toISOString(),
    booking: {
      id: "b-1",
      confirmationCode: "ABC12345",
      user: { fullName: "John Smith" },
    },
    rangefinderDevice: { id: "d-1", name: "Cart GPS #1", deviceType: "CART_GPS" },
  },
  {
    id: "pl-2",
    latitude: 33.45,
    longitude: -112.075,
    accuracyMeters: 5.2,
    currentHole: 3,
    recordedAt: new Date(Date.now() - 3 * 60 * 1000).toISOString(),
    booking: {
      id: "b-2",
      confirmationCode: "DEF67890",
      user: { fullName: "Jane Doe" },
    },
    rangefinderDevice: null,
  },
  {
    id: "pl-3",
    latitude: 33.451,
    longitude: -112.073,
    accuracyMeters: 8.0,
    currentHole: 7,
    recordedAt: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
    booking: {
      id: "b-3",
      confirmationCode: "GHI11223",
      user: { fullName: "Bob Wilson" },
    },
    rangefinderDevice: { id: "d-2", name: "Cart GPS #2", deviceType: "CART_GPS" },
  },
  {
    id: "pl-4",
    latitude: 33.452,
    longitude: -112.076,
    accuracyMeters: 12.0,
    currentHole: 12,
    recordedAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    booking: {
      id: "b-4",
      confirmationCode: "JKL44556",
      user: { fullName: "Alice Johnson" },
    },
    rangefinderDevice: null,
  },
];

const withPlayersMocks = [
  {
    request: {
      query: GET_PLAYER_LOCATIONS,
      variables: { courseId: "c-1" },
    },
    result: {
      data: { playerLocations: mockLocations },
    },
  },
];

const emptyMocks = [
  {
    request: {
      query: GET_PLAYER_LOCATIONS,
      variables: { courseId: "c-empty" },
    },
    result: {
      data: { playerLocations: [] },
    },
  },
];

export const WithPlayers: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={withPlayersMocks} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    courseId: "c-1",
  },
};

export const NoPlayers: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={emptyMocks} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    courseId: "c-empty",
  },
};
