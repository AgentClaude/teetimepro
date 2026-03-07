import type { Meta, StoryObj } from '@storybook/react';
import { ResultsTable } from './ResultsTable';

const meta: Meta<typeof ResultsTable> = {
  title: 'Tournament/ResultsTable',
  component: ResultsTable,
  parameters: {
    layout: 'padded',
  },
  decorators: [
    (Story: React.ComponentType) => (
      <div className="max-w-5xl">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof ResultsTable>;

const mockResults = [
  {
    id: '1',
    position: 1,
    positionDisplay: '1',
    tournamentEntry: {
      id: 'entry1',
      user: {
        id: 'user1',
        firstName: 'John',
        lastName: 'Smith',
      },
      teamName: undefined,
    },
    totalStrokes: 69,
    totalToPar: -3,
    toParDisplay: '-3',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '2',
    position: 2,
    positionDisplay: '2',
    tournamentEntry: {
      id: 'entry2',
      user: {
        id: 'user2',
        firstName: 'Sarah',
        lastName: 'Johnson',
      },
      teamName: undefined,
    },
    totalStrokes: 71,
    totalToPar: -1,
    toParDisplay: '-1',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '3',
    position: 3,
    positionDisplay: '3',
    tournamentEntry: {
      id: 'entry3',
      user: {
        id: 'user3',
        firstName: 'Mike',
        lastName: 'Davis',
      },
      teamName: undefined,
    },
    totalStrokes: 72,
    totalToPar: 0,
    toParDisplay: 'E',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '4',
    position: 4,
    positionDisplay: '4',
    tournamentEntry: {
      id: 'entry4',
      user: {
        id: 'user4',
        firstName: 'Lisa',
        lastName: 'Wilson',
      },
      teamName: undefined,
    },
    totalStrokes: 74,
    totalToPar: 2,
    toParDisplay: '+2',
    tied: false,
    prizeAwarded: false,
    finalized: true,
  },
];

const mockPrizes = [
  {
    id: '1',
    position: 1,
    prizeType: 'Cash',
    description: 'First Place Winner',
    amountDisplay: '$500.00',
    awarded: true,
    awardedTo: {
      id: 'entry1',
    },
  },
  {
    id: '2',
    position: 2,
    prizeType: 'Cash',
    description: 'Second Place',
    amountDisplay: '$250.00',
    awarded: true,
    awardedTo: {
      id: 'entry2',
    },
  },
  {
    id: '3',
    position: 3,
    prizeType: 'Trophy',
    description: 'Third Place Trophy',
    amountDisplay: '$0.00',
    awarded: true,
    awardedTo: {
      id: 'entry3',
    },
  },
];

const tiedResults = [
  {
    id: '1',
    position: 1,
    positionDisplay: 'T1',
    tournamentEntry: {
      id: 'entry1',
      user: {
        id: 'user1',
        firstName: 'Player',
        lastName: 'One',
      },
    },
    totalStrokes: 70,
    totalToPar: -2,
    toParDisplay: '-2',
    tied: true,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '2',
    position: 1,
    positionDisplay: 'T1',
    tournamentEntry: {
      id: 'entry2',
      user: {
        id: 'user2',
        firstName: 'Player',
        lastName: 'Two',
      },
    },
    totalStrokes: 70,
    totalToPar: -2,
    toParDisplay: '-2',
    tied: true,
    prizeAwarded: false,
    finalized: true,
  },
  {
    id: '3',
    position: 3,
    positionDisplay: '3',
    tournamentEntry: {
      id: 'entry3',
      user: {
        id: 'user3',
        firstName: 'Player',
        lastName: 'Three',
      },
    },
    totalStrokes: 72,
    totalToPar: 0,
    toParDisplay: 'E',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
];

const teamResults = [
  {
    id: '1',
    position: 1,
    positionDisplay: '1',
    tournamentEntry: {
      id: 'entry1',
      user: {
        id: 'user1',
        firstName: 'John',
        lastName: 'Smith',
      },
      teamName: 'Eagles',
    },
    totalStrokes: 68,
    totalToPar: -4,
    toParDisplay: '-4',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '2',
    position: 2,
    positionDisplay: '2',
    tournamentEntry: {
      id: 'entry2',
      user: {
        id: 'user2',
        firstName: 'Mike',
        lastName: 'Johnson',
      },
      teamName: 'Birdies',
    },
    totalStrokes: 70,
    totalToPar: -2,
    toParDisplay: '-2',
    tied: false,
    prizeAwarded: true,
    finalized: true,
  },
  {
    id: '3',
    position: 3,
    positionDisplay: '3',
    tournamentEntry: {
      id: 'entry3',
      user: {
        id: 'user3',
        firstName: 'Sarah',
        lastName: 'Davis',
      },
      teamName: 'Pars',
    },
    totalStrokes: 72,
    totalToPar: 0,
    toParDisplay: 'E',
    tied: false,
    prizeAwarded: false,
    finalized: true,
  },
];

const preliminaryResults = [
  {
    ...mockResults[0],
    finalized: false,
    prizeAwarded: false,
  },
  {
    ...mockResults[1],
    finalized: false,
    prizeAwarded: false,
  },
  {
    ...mockResults[2],
    finalized: false,
    prizeAwarded: false,
  },
  {
    ...mockResults[3],
    finalized: false,
    prizeAwarded: false,
  },
];

export const Default: Story = {
  args: {
    results: mockResults,
    prizes: mockPrizes,
    title: 'Final Results',
    showPrizes: true,
  },
};

export const WithoutPrizes: Story = {
  args: {
    results: mockResults,
    title: 'Tournament Results',
    showPrizes: false,
  },
};

export const TiedPositions: Story = {
  args: {
    results: tiedResults,
    prizes: mockPrizes,
    title: 'Results with Ties',
    showPrizes: true,
  },
};

export const TeamCompetition: Story = {
  args: {
    results: teamResults,
    prizes: mockPrizes,
    title: 'Team Championship Results',
    showPrizes: true,
  },
};

export const PreliminaryResults: Story = {
  args: {
    results: preliminaryResults,
    title: 'Preliminary Results',
    showPrizes: false,
  },
};

export const LargeField: Story = {
  args: {
    results: [
      ...mockResults,
      {
        id: '5',
        position: 5,
        positionDisplay: '5',
        tournamentEntry: {
          id: 'entry5',
          user: {
            id: 'user5',
            firstName: 'Tom',
            lastName: 'Brown',
          },
        },
        totalStrokes: 75,
        totalToPar: 3,
        toParDisplay: '+3',
        tied: false,
        prizeAwarded: false,
        finalized: true,
      },
      {
        id: '6',
        position: 6,
        positionDisplay: 'T6',
        tournamentEntry: {
          id: 'entry6',
          user: {
            id: 'user6',
            firstName: 'Emma',
            lastName: 'Taylor',
          },
        },
        totalStrokes: 76,
        totalToPar: 4,
        toParDisplay: '+4',
        tied: true,
        prizeAwarded: false,
        finalized: true,
      },
      {
        id: '7',
        position: 6,
        positionDisplay: 'T6',
        tournamentEntry: {
          id: 'entry7',
          user: {
            id: 'user7',
            firstName: 'Alex',
            lastName: 'Anderson',
          },
        },
        totalStrokes: 76,
        totalToPar: 4,
        toParDisplay: '+4',
        tied: true,
        prizeAwarded: false,
        finalized: true,
      },
      {
        id: '8',
        position: 8,
        positionDisplay: '8',
        tournamentEntry: {
          id: 'entry8',
          user: {
            id: 'user8',
            firstName: 'Chris',
            lastName: 'Martinez',
          },
        },
        totalStrokes: 78,
        totalToPar: 6,
        toParDisplay: '+6',
        tied: false,
        prizeAwarded: false,
        finalized: true,
      },
    ],
    prizes: mockPrizes,
    title: 'Championship Field',
    showPrizes: true,
  },
};

export const Empty: Story = {
  args: {
    results: [],
    title: 'Tournament Results',
    showPrizes: true,
  },
};