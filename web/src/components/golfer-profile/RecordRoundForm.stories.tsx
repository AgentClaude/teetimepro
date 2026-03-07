import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { RecordRoundForm } from './RecordRoundForm';
import { RECORD_ROUND } from '../../graphql/golferProfile';

const meta: Meta<typeof RecordRoundForm> = {
  title: 'GolferProfile/RecordRoundForm',
  component: RecordRoundForm,
  decorators: [
    (Story) => (
      <MockedProvider
        mocks={[
          {
            request: {
              query: RECORD_ROUND,
              variables: {
                golferProfileId: '1',
                courseName: 'Test Course',
                playedOn: '2026-03-07',
                score: 85,
                holesPlayed: 18,
              },
            },
            result: {
              data: {
                recordRound: {
                  round: {
                    id: '1',
                    courseName: 'Test Course',
                    playedOn: '2026-03-07',
                    score: 85,
                    differential: 10.9,
                  },
                  golferProfile: {
                    id: '1',
                    handicapIndex: 12.5,
                    totalRounds: 1,
                    bestScore: 85,
                    averageScore: 85.0,
                    lastPlayedOn: '2026-03-07',
                    displayHandicap: '12.5',
                  },
                  errors: [],
                },
              },
            },
          },
        ]}
        addTypename={false}
      >
        <Story />
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof RecordRoundForm>;

export const Default: Story = {
  args: {
    profileId: '1',
  },
};

export const WithCancel: Story = {
  args: {
    profileId: '1',
    onCancel: () => alert('Cancelled'),
  },
};
