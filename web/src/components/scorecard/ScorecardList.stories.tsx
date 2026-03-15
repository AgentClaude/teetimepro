import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { ScorecardList } from './ScorecardList';
import { GET_SCORECARDS } from '../../graphql/queries';

const meta: Meta<typeof ScorecardList> = {
  title: 'Scorecard/ScorecardList',
  component: ScorecardList,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof ScorecardList>;

const mockScorecards = [
  {
    id: 'sc-1',
    course: { id: 'c-1', name: 'Pine Valley Golf Club' },
    playedOn: '2026-03-08',
    holesPlayed: 18,
    totalStrokes: 82,
    scoreToPar: 10,
    status: 'COMPLETED',
    holesCompleted: 18,
    completedAt: '2026-03-08T14:30:00Z',
  },
  {
    id: 'sc-2',
    course: { id: 'c-2', name: 'Augusta National' },
    playedOn: '2026-03-07',
    holesPlayed: 18,
    totalStrokes: 45,
    scoreToPar: 9,
    status: 'IN_PROGRESS',
    holesCompleted: 12,
    completedAt: null,
  },
  {
    id: 'sc-3',
    course: { id: 'c-1', name: 'Pine Valley Golf Club' },
    playedOn: '2026-03-05',
    holesPlayed: 9,
    totalStrokes: null,
    scoreToPar: null,
    status: 'ABANDONED',
    holesCompleted: 3,
    completedAt: null,
  },
];

const scorecardsMock = {
  request: {
    query: GET_SCORECARDS,
    variables: { golferProfileId: 'gp-1', status: undefined, limit: 20 },
  },
  result: { data: { scorecards: mockScorecards } },
};

const emptyMock = {
  request: {
    query: GET_SCORECARDS,
    variables: { golferProfileId: 'gp-2', status: undefined, limit: 20 },
  },
  result: { data: { scorecards: [] } },
};

export const WithScorecards: Story = {
  args: {
    golferProfileId: 'gp-1',
    onSelect: (id: string) => console.log('Selected:', id),
  },
  decorators: [
    (Story) => (
      <MockedProvider mocks={[scorecardsMock]} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export const EmptyState: Story = {
  args: {
    golferProfileId: 'gp-2',
  },
  decorators: [
    (Story) => (
      <MockedProvider mocks={[emptyMock]} addTypename={false}>
        <div className="max-w-2xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};
