import type { Meta, StoryObj } from '@storybook/react';
import { HandicapHistory } from './HandicapHistory';

const meta: Meta<typeof HandicapHistory> = {
  title: 'GolferProfile/HandicapHistory',
  component: HandicapHistory,
};

export default meta;
type Story = StoryObj<typeof HandicapHistory>;

const sampleRevisions = [
  {
    id: '1',
    handicapIndex: 12.5,
    previousIndex: 13.2,
    change: -0.7,
    effectiveDate: '2026-03-01',
    source: 'calculated',
    roundsUsed: 5,
  },
  {
    id: '2',
    handicapIndex: 13.2,
    previousIndex: 14.0,
    change: -0.8,
    effectiveDate: '2026-02-15',
    source: 'calculated',
    roundsUsed: 4,
  },
  {
    id: '3',
    handicapIndex: 14.0,
    previousIndex: 13.5,
    change: 0.5,
    effectiveDate: '2026-02-01',
    source: 'calculated',
    roundsUsed: 3,
  },
  {
    id: '4',
    handicapIndex: 13.5,
    previousIndex: null,
    change: null,
    effectiveDate: '2026-01-15',
    source: 'manual',
    roundsUsed: 0,
  },
];

export const WithHistory: Story = {
  args: {
    revisions: sampleRevisions,
    currentIndex: 12.5,
  },
};

export const Empty: Story = {
  args: {
    revisions: [],
    currentIndex: null,
  },
};

export const SingleEntry: Story = {
  args: {
    revisions: [sampleRevisions[3]],
    currentIndex: 13.5,
  },
};
