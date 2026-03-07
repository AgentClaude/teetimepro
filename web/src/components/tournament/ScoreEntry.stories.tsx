import type { Meta, StoryObj } from "@storybook/react";
import { ScoreEntry } from "./ScoreEntry";
import { MockedProvider } from "@apollo/client/testing";

const STANDARD_18_PARS = [
  { hole: 1, par: 4 },
  { hole: 2, par: 4 },
  { hole: 3, par: 5 },
  { hole: 4, par: 3 },
  { hole: 5, par: 4 },
  { hole: 6, par: 4 },
  { hole: 7, par: 3 },
  { hole: 8, par: 5 },
  { hole: 9, par: 4 },
  { hole: 10, par: 4 },
  { hole: 11, par: 4 },
  { hole: 12, par: 3 },
  { hole: 13, par: 5 },
  { hole: 14, par: 4 },
  { hole: 15, par: 4 },
  { hole: 16, par: 3 },
  { hole: 17, par: 4 },
  { hole: 18, par: 5 },
];

const SAMPLE_ENTRIES = [
  { entryId: "1", playerId: "101", playerName: "Tiger Woods" },
  { entryId: "2", playerId: "102", playerName: "Rory McIlroy" },
  { entryId: "3", playerId: "103", playerName: "Phil Mickelson" },
  { entryId: "4", playerId: "104", playerName: "Jon Rahm" },
];

const EXISTING_SCORES = {
  "1": [
    { holeNumber: 1, strokes: 3, par: 4, putts: 1, fairwayHit: true, greenInRegulation: true },
    { holeNumber: 2, strokes: 4, par: 4, putts: 2, fairwayHit: true, greenInRegulation: false },
    { holeNumber: 3, strokes: 5, par: 5, putts: 2, fairwayHit: true, greenInRegulation: true },
    { holeNumber: 4, strokes: 2, par: 3, putts: 1, fairwayHit: null, greenInRegulation: true },
  ],
};

const meta: Meta<typeof ScoreEntry> = {
  title: "Tournament/ScoreEntry",
  component: ScoreEntry,
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <div className="max-w-lg mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  parameters: {
    layout: "centered",
  },
};

export default meta;
type Story = StoryObj<typeof ScoreEntry>;

export const Default: Story = {
  args: {
    tournamentId: "1",
    roundId: "1",
    roundNumber: 1,
    entries: SAMPLE_ENTRIES,
    holePars: STANDARD_18_PARS,
  },
};

export const WithExistingScores: Story = {
  args: {
    tournamentId: "1",
    roundId: "1",
    roundNumber: 2,
    entries: SAMPLE_ENTRIES,
    holePars: STANDARD_18_PARS,
    existingScores: EXISTING_SCORES,
  },
};

export const NineHoles: Story = {
  args: {
    tournamentId: "1",
    roundId: "1",
    roundNumber: 1,
    entries: SAMPLE_ENTRIES.slice(0, 2),
    holePars: STANDARD_18_PARS.slice(0, 9),
  },
};

export const SinglePlayer: Story = {
  args: {
    tournamentId: "1",
    roundId: "1",
    roundNumber: 1,
    entries: [SAMPLE_ENTRIES[0]],
    holePars: STANDARD_18_PARS,
  },
};
