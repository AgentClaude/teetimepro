import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { ScorecardGrid } from './ScorecardGrid';
import { UPDATE_HOLE_SCORE } from '../../graphql/mutations';
import type { Scorecard, HoleScore } from '../../types/scorecard';

const meta: Meta<typeof ScorecardGrid> = {
  title: 'Scorecard/ScorecardGrid',
  component: ScorecardGrid,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <MockedProvider mocks={defaultMocks} addTypename={false}>
        <div className="max-w-4xl mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof ScorecardGrid>;

function makeHoleScores(scored: number = 0): HoleScore[] {
  const pars = [4, 4, 3, 4, 5, 4, 3, 4, 5, 4, 4, 3, 4, 5, 4, 3, 4, 5];
  return pars.map((par, i) => ({
    id: `hs-${i + 1}`,
    holeNumber: i + 1,
    par,
    strokes: i < scored ? par + Math.floor(Math.random() * 3) - 1 : null,
    putts: i < scored ? Math.floor(Math.random() * 3) + 1 : null,
    fairwayHit: i < scored ? Math.random() > 0.4 : null,
    greenInRegulation: i < scored ? Math.random() > 0.5 : null,
    penalties: i < scored ? (Math.random() > 0.8 ? 1 : 0) : null,
    scoreToPar: i < scored ? Math.floor(Math.random() * 3) - 1 : null,
    notes: null,
  }));
}

function makeScorecard(overrides: Partial<Scorecard> = {}): Scorecard {
  const holeScores = overrides.holeScores ?? makeHoleScores();
  const scored = holeScores.filter((h) => h.strokes !== null);
  return {
    id: 'sc-1',
    golferProfile: { id: 'gp-1', displayName: 'James W.', handicapIndex: 14.2 },
    course: { id: 'c-1', name: 'Pine Valley Golf Club' },
    bookingId: null,
    playedOn: '2026-03-08',
    holesPlayed: 18,
    totalStrokes: scored.length ? scored.reduce((s, h) => s + (h.strokes ?? 0), 0) : null,
    totalPutts: scored.length ? scored.reduce((s, h) => s + (h.putts ?? 0), 0) : null,
    totalFairwaysHit: scored.filter((h) => h.fairwayHit).length,
    totalGreensInRegulation: scored.filter((h) => h.greenInRegulation).length,
    totalPenalties: scored.reduce((s, h) => s + (h.penalties ?? 0), 0),
    frontNineStrokes: scored.filter((h) => h.holeNumber <= 9).reduce((s, h) => s + (h.strokes ?? 0), 0) || null,
    backNineStrokes: scored.filter((h) => h.holeNumber > 9).reduce((s, h) => s + (h.strokes ?? 0), 0) || null,
    scoreToPar: scored.length ? scored.reduce((s, h) => s + (h.scoreToPar ?? 0), 0) : null,
    status: 'IN_PROGRESS',
    teeColor: 'White',
    courseRating: 72.1,
    slopeRating: 131,
    notes: null,
    startedAt: '2026-03-08T10:00:00Z',
    completedAt: null,
    createdAt: '2026-03-08T09:55:00Z',
    holesCompleted: scored.length,
    holeScores,
    ...overrides,
  };
}

const defaultMocks = [
  {
    request: { query: UPDATE_HOLE_SCORE, variables: {} },
    variableMatcher: () => true,
    result: {
      data: {
        updateHoleScore: {
          holeScore: { id: 'hs-1', holeNumber: 1, par: 4, strokes: 4, putts: 2, fairwayHit: true, greenInRegulation: true, penalties: 0, scoreToPar: 0 },
          scorecard: { id: 'sc-1', totalStrokes: 72, totalPutts: 32, totalFairwaysHit: 10, totalGreensInRegulation: 12, totalPenalties: 1, frontNineStrokes: 36, backNineStrokes: 36, scoreToPar: 0, holesCompleted: 18 },
          errors: [],
        },
      },
    },
  },
];

export const EmptyScorecard: Story = {
  args: {
    scorecard: makeScorecard(),
  },
};

export const PartiallyScored: Story = {
  args: {
    scorecard: makeScorecard({ holeScores: makeHoleScores(9) }),
  },
};

export const FullyScored: Story = {
  args: {
    scorecard: makeScorecard({ holeScores: makeHoleScores(18) }),
  },
};

export const CompletedScorecard: Story = {
  args: {
    scorecard: makeScorecard({
      status: 'COMPLETED',
      holeScores: makeHoleScores(18),
      completedAt: '2026-03-08T14:30:00Z',
    }),
  },
};

export const NineHoles: Story = {
  args: {
    scorecard: makeScorecard({
      holesPlayed: 9,
      holeScores: makeHoleScores().slice(0, 9),
    }),
  },
};
