import type { Meta, StoryObj } from '@storybook/react';
import { GolferProfileStats } from './GolferProfileStats';

const meta: Meta<typeof GolferProfileStats> = {
  title: 'GolferProfile/GolferProfileStats',
  component: GolferProfileStats,
};

export default meta;
type Story = StoryObj<typeof GolferProfileStats>;

export const WithAllStats: Story = {
  args: {
    profile: {
      displayHandicap: '12.5',
      handicapIndex: 12.5,
      totalRounds: 47,
      bestScore: 78,
      averageScore: 88.3,
      lastPlayedOn: '2026-03-01',
      homeCourse: 'Pine Valley Golf Club',
      preferredTee: 'white',
      handicapUpdatedAt: '2026-03-01T12:00:00Z',
    },
  },
};

export const NewGolfer: Story = {
  args: {
    profile: {
      displayHandicap: 'N/A',
      handicapIndex: null,
      totalRounds: 0,
      bestScore: null,
      averageScore: null,
      lastPlayedOn: null,
      homeCourse: null,
      preferredTee: null,
      handicapUpdatedAt: null,
    },
  },
};

export const LowHandicap: Story = {
  args: {
    profile: {
      displayHandicap: '+2.3',
      handicapIndex: 2.3,
      totalRounds: 150,
      bestScore: 65,
      averageScore: 72.1,
      lastPlayedOn: '2026-03-05',
      homeCourse: 'Augusta National',
      preferredTee: 'black',
      handicapUpdatedAt: '2026-03-05T12:00:00Z',
    },
  },
};
