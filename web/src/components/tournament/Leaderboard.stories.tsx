import type { Meta, StoryObj } from "@storybook/react";
import { MockedProvider } from "@apollo/client/testing";
import { gql } from "@apollo/client";
import { Leaderboard, type LeaderboardProps } from "./Leaderboard";

const LEADERBOARD_QUERY = gql`
  query TournamentLeaderboard($tournamentId: ID!) {
    tournamentLeaderboard(tournamentId: $tournamentId) {
      tournamentId
      totalRounds
      currentRound
      entries {
        position
        tied
        entryId
        playerId
        playerName
        teamName
        handicapIndex
        totalStrokes
        totalToPar
        totalHolesPlayed
        thru
        rounds {
          roundNumber
          totalStrokes
          scoreToPar
          holesPlayed
          completed
        }
      }
    }
  }
`;

const sampleEntries = [
  {
    position: 1,
    tied: false,
    entryId: "1",
    playerId: "p1",
    playerName: "Tiger Woods",
    teamName: null,
    handicapIndex: 2.1,
    totalStrokes: 68,
    totalToPar: -4,
    totalHolesPlayed: 18,
    thru: "F",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 68,
        scoreToPar: -4,
        holesPlayed: 18,
        completed: true,
      },
    ],
  },
  {
    position: 2,
    tied: true,
    entryId: "2",
    playerId: "p2",
    playerName: "Rory McIlroy",
    teamName: null,
    handicapIndex: 1.8,
    totalStrokes: 70,
    totalToPar: -2,
    totalHolesPlayed: 18,
    thru: "F",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 70,
        scoreToPar: -2,
        holesPlayed: 18,
        completed: true,
      },
    ],
  },
  {
    position: 2,
    tied: true,
    entryId: "3",
    playerId: "p3",
    playerName: "Jon Rahm",
    teamName: null,
    handicapIndex: 3.0,
    totalStrokes: 70,
    totalToPar: -2,
    totalHolesPlayed: 18,
    thru: "F",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 70,
        scoreToPar: -2,
        holesPlayed: 18,
        completed: true,
      },
    ],
  },
  {
    position: 4,
    tied: false,
    entryId: "4",
    playerId: "p4",
    playerName: "Phil Mickelson",
    teamName: null,
    handicapIndex: 5.2,
    totalStrokes: 72,
    totalToPar: 0,
    totalHolesPlayed: 18,
    thru: "F",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 72,
        scoreToPar: 0,
        holesPlayed: 18,
        completed: true,
      },
    ],
  },
  {
    position: 5,
    tied: false,
    entryId: "5",
    playerId: "p5",
    playerName: "Dustin Johnson",
    teamName: null,
    handicapIndex: 4.0,
    totalStrokes: 74,
    totalToPar: 2,
    totalHolesPlayed: 18,
    thru: "F",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 74,
        scoreToPar: 2,
        holesPlayed: 18,
        completed: true,
      },
    ],
  },
];

const inProgressEntries = [
  {
    ...sampleEntries[0],
    totalStrokes: 31,
    totalToPar: -5,
    totalHolesPlayed: 9,
    thru: "9",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 31,
        scoreToPar: -5,
        holesPlayed: 9,
        completed: false,
      },
    ],
  },
  {
    ...sampleEntries[1],
    position: 2,
    tied: false,
    totalStrokes: 34,
    totalToPar: -2,
    totalHolesPlayed: 9,
    thru: "9",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 34,
        scoreToPar: -2,
        holesPlayed: 9,
        completed: false,
      },
    ],
  },
  {
    ...sampleEntries[3],
    position: 3,
    totalStrokes: 28,
    totalToPar: -1,
    totalHolesPlayed: 7,
    thru: "7",
    rounds: [
      {
        roundNumber: 1,
        totalStrokes: 28,
        scoreToPar: -1,
        holesPlayed: 7,
        completed: false,
      },
    ],
  },
];

function createMock(
  entries: typeof sampleEntries,
  totalRounds = 1,
  currentRound: number | null = 1
) {
  return {
    request: {
      query: LEADERBOARD_QUERY,
      variables: { tournamentId: "1" },
    },
    result: {
      data: {
        tournamentLeaderboard: {
          tournamentId: "1",
          totalRounds,
          currentRound,
          entries,
        },
      },
    },
  };
}

interface LeaderboardStoryProps extends LeaderboardProps {
  _mocks?: ReturnType<typeof createMock>[];
}

const meta: Meta<LeaderboardStoryProps> = {
  title: "Tournament/Leaderboard",
  component: Leaderboard,
  parameters: {
    layout: "padded",
  },
  decorators: [
    (Story, context) => (
      <MockedProvider
        mocks={(context.args as LeaderboardStoryProps)._mocks ?? []}
        addTypename={false}
      >
        <div className="max-w-4xl mx-auto">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<LeaderboardStoryProps>;

export const CompletedRound: Story = {
  args: {
    tournamentId: "1",
    tournamentName: "Spring Classic 2026",
    realTime: false,
    _mocks: [createMock(sampleEntries)],
  },
};

export const InProgress: Story = {
  args: {
    tournamentId: "1",
    tournamentName: "Weekend Invitational",
    realTime: false,
    _mocks: [createMock(inProgressEntries, 1, 1)],
  },
};

export const MultiRound: Story = {
  args: {
    tournamentId: "1",
    tournamentName: "Club Championship",
    realTime: false,
    _mocks: [
      createMock(
        sampleEntries.map((e) => ({
          ...e,
          totalStrokes: e.totalStrokes + 71,
          totalToPar: e.totalToPar - 1,
          totalHolesPlayed: 36,
          thru: "F",
          rounds: [
            ...e.rounds,
            {
              roundNumber: 2,
              totalStrokes: 71,
              scoreToPar: -1,
              holesPlayed: 18,
              completed: true,
            },
          ],
        })),
        2,
        null
      ),
    ],
  },
};

export const Empty: Story = {
  args: {
    tournamentId: "1",
    tournamentName: "New Tournament",
    realTime: false,
    _mocks: [createMock([], 1, null)],
  },
};
