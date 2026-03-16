import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { GpsFeatureList } from "./GpsFeatureList";
import { GET_COURSE_GPS_FEATURES } from "../../graphql/gps-queries";

const meta: Meta<typeof GpsFeatureList> = {
  title: "GPS/GpsFeatureList",
  component: GpsFeatureList,
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof GpsFeatureList>;

const mockFeatures = [
  {
    id: "1",
    name: "Tee Box",
    featureType: "TEE_BOX",
    latitude: 33.448,
    longitude: -112.074,
    elevationFeet: null,
    distanceFromTeeYards: 0,
    metadata: {},
    courseHole: { id: "h1", holeNumber: 1, par: 4 },
    createdAt: "2026-03-15T10:00:00Z",
  },
  {
    id: "2",
    name: "Green Center",
    featureType: "GREEN_CENTER",
    latitude: 33.4515,
    longitude: -112.074,
    elevationFeet: 245.5,
    distanceFromTeeYards: 385,
    metadata: {},
    courseHole: { id: "h1", holeNumber: 1, par: 4 },
    createdAt: "2026-03-15T10:00:00Z",
  },
  {
    id: "3",
    name: "Fairway Bunker (L)",
    featureType: "BUNKER",
    latitude: 33.45,
    longitude: -112.0742,
    elevationFeet: null,
    distanceFromTeeYards: 220,
    metadata: {},
    courseHole: { id: "h1", holeNumber: 1, par: 4 },
    createdAt: "2026-03-15T10:00:00Z",
  },
  {
    id: "4",
    name: "Water Hazard",
    featureType: "WATER_HAZARD",
    latitude: 33.451,
    longitude: -112.074,
    elevationFeet: null,
    distanceFromTeeYards: 300,
    metadata: {},
    courseHole: { id: "h1", holeNumber: 1, par: 4 },
    createdAt: "2026-03-15T10:00:00Z",
  },
  {
    id: "5",
    name: "Green Center",
    featureType: "GREEN_CENTER",
    latitude: 33.449,
    longitude: -112.075,
    elevationFeet: 260.0,
    distanceFromTeeYards: 165,
    metadata: {},
    courseHole: { id: "h2", holeNumber: 2, par: 3 },
    createdAt: "2026-03-15T10:00:00Z",
  },
];

const defaultMocks = [
  {
    request: {
      query: GET_COURSE_GPS_FEATURES,
      variables: { courseId: "c-1" },
    },
    result: {
      data: { courseGpsFeatures: mockFeatures },
    },
  },
];

const emptyMocks = [
  {
    request: {
      query: GET_COURSE_GPS_FEATURES,
      variables: { courseId: "c-empty" },
    },
    result: {
      data: { courseGpsFeatures: [] },
    },
  },
];

export const WithFeatures: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={defaultMocks} addTypename={false}>
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

export const Empty: Story = {
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
