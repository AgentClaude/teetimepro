import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { RangefinderDeviceManager } from "./RangefinderDeviceManager";
import { GET_RANGEFINDER_DEVICES } from "../../graphql/gps-queries";

const meta: Meta<typeof RangefinderDeviceManager> = {
  title: "GPS/RangefinderDeviceManager",
  component: RangefinderDeviceManager,
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof RangefinderDeviceManager>;

const mockDevices = [
  {
    id: "d-1",
    deviceId: "GPS-001",
    name: "Cart GPS #1",
    deviceType: "CART_GPS",
    status: "ACTIVE",
    firmwareVersion: "2.1.0",
    batteryLevel: 85.5,
    online: true,
    lastSeenAt: new Date().toISOString(),
    metadata: {},
    createdAt: "2026-03-01T08:00:00Z",
  },
  {
    id: "d-2",
    deviceId: "GPS-002",
    name: "Cart GPS #2",
    deviceType: "CART_GPS",
    status: "ACTIVE",
    firmwareVersion: "2.1.0",
    batteryLevel: 42.0,
    online: true,
    lastSeenAt: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
    metadata: {},
    createdAt: "2026-03-01T08:00:00Z",
  },
  {
    id: "d-3",
    deviceId: "WATCH-001",
    name: "Pro Shop Watch",
    deviceType: "WATCH_GPS",
    status: "ACTIVE",
    firmwareVersion: "1.5.2",
    batteryLevel: 12.0,
    online: false,
    lastSeenAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    metadata: {},
    createdAt: "2026-03-05T10:00:00Z",
  },
  {
    id: "d-4",
    deviceId: "LRF-001",
    name: "Laser Rangefinder A",
    deviceType: "LASER_RANGEFINDER",
    status: "MAINTENANCE",
    firmwareVersion: "3.0.1",
    batteryLevel: null,
    online: false,
    lastSeenAt: null,
    metadata: {},
    createdAt: "2026-02-15T12:00:00Z",
  },
];

const withDevicesMocks = [
  {
    request: {
      query: GET_RANGEFINDER_DEVICES,
      variables: {},
    },
    result: {
      data: { rangefinderDevices: mockDevices },
    },
  },
];

const emptyMocks = [
  {
    request: {
      query: GET_RANGEFINDER_DEVICES,
      variables: {},
    },
    result: {
      data: { rangefinderDevices: [] },
    },
  },
];

export const WithDevices: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={withDevicesMocks} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const NoDevices: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={emptyMocks} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};
