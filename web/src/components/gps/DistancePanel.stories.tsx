import type { Meta, StoryObj } from "@storybook/react";
import { DistancePanel } from "./DistancePanel";
import type { DistanceMeasurement } from "../../types/gps";

const meta: Meta<typeof DistancePanel> = {
  title: "GPS/DistancePanel",
  component: DistancePanel,
  tags: ["autodocs"],
  decorators: [
    (Story) => (
      <div className="max-w-md mx-auto p-4">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof DistancePanel>;

const sampleDistances: DistanceMeasurement[] = [
  {
    featureId: "1",
    featureName: "Pin Position",
    featureType: "PIN_POSITION",
    distanceYards: 142,
  },
  {
    featureId: "2",
    featureName: "Green Center",
    featureType: "GREEN_CENTER",
    distanceYards: 148,
  },
  {
    featureId: "3",
    featureName: "Front of Green",
    featureType: "GREEN_FRONT",
    distanceYards: 132,
  },
  {
    featureId: "4",
    featureName: "Back of Green",
    featureType: "GREEN_BACK",
    distanceYards: 165,
  },
  {
    featureId: "5",
    featureName: "Greenside Bunker (R)",
    featureType: "BUNKER",
    distanceYards: 138,
  },
  {
    featureId: "6",
    featureName: "Water Hazard",
    featureType: "WATER_HAZARD",
    distanceYards: 110,
  },
  {
    featureId: "7",
    featureName: "Fairway Center",
    featureType: "FAIRWAY_CENTER",
    distanceYards: 85,
  },
];

export const Default: Story = {
  args: {
    distances: sampleDistances,
    holeNumber: 7,
    par: 4,
  },
};

export const CloseToGreen: Story = {
  args: {
    distances: [
      {
        featureId: "1",
        featureName: "Pin Position",
        featureType: "PIN_POSITION",
        distanceYards: 32,
      },
      {
        featureId: "2",
        featureName: "Green Center",
        featureType: "GREEN_CENTER",
        distanceYards: 28,
      },
      {
        featureId: "3",
        featureName: "Greenside Bunker",
        featureType: "BUNKER",
        distanceYards: 15,
      },
    ],
    holeNumber: 3,
    par: 3,
  },
};

export const Empty: Story = {
  args: {
    distances: [],
    holeNumber: 1,
    par: 4,
  },
};

export const LongPar5: Story = {
  args: {
    distances: [
      {
        featureId: "1",
        featureName: "Green Center",
        featureType: "GREEN_CENTER",
        distanceYards: 285,
      },
      {
        featureId: "2",
        featureName: "Layup Target",
        featureType: "LAYUP",
        distanceYards: 95,
      },
      {
        featureId: "3",
        featureName: "Fairway Bunker",
        featureType: "BUNKER",
        distanceYards: 180,
      },
      {
        featureId: "4",
        featureName: "Water (Crossing)",
        featureType: "WATER_HAZARD",
        distanceYards: 210,
      },
    ],
    holeNumber: 15,
    par: 5,
  },
};
