import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { PlayHistory } from './PlayHistory';

const meta: Meta<typeof PlayHistory> = {
  title: 'GolferProfile/PlayHistory',
  component: PlayHistory,
  decorators: [
    (Story) => (
      <MockedProvider mocks={[]} addTypename={false}>
        <Story />
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof PlayHistory>;

const sampleRounds = [
  {
    id: '1',
    courseName: 'Pine Valley Golf Club',
    playedOn: '2026-03-01',
    score: 82,
    holesPlayed: 18,
    courseRating: 72.5,
    slopeRating: 130,
    differential: 8.3,
    teeColor: 'white',
    putts: 31,
    fairwaysHit: 9,
    greensInRegulation: 11,
    notes: null,
  },
  {
    id: '2',
    courseName: 'Augusta National',
    playedOn: '2026-02-25',
    score: 88,
    holesPlayed: 18,
    courseRating: 76.2,
    slopeRating: 148,
    differential: 9.0,
    teeColor: 'blue',
    putts: 34,
    fairwaysHit: 7,
    greensInRegulation: 8,
    notes: null,
  },
  {
    id: '3',
    courseName: 'Local Muni',
    playedOn: '2026-02-20',
    score: 42,
    holesPlayed: 9,
    courseRating: null,
    slopeRating: null,
    differential: null,
    teeColor: null,
    putts: null,
    fairwaysHit: null,
    greensInRegulation: null,
    notes: 'Quick round after work',
  },
];

export const WithRounds: Story = {
  args: {
    profileId: '1',
    initialRounds: sampleRounds,
  },
};

export const Empty: Story = {
  args: {
    profileId: '1',
    initialRounds: [],
  },
};
