import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { SegmentFilterBuilder } from './SegmentFilterBuilder';
import { PREVIEW_GOLFER_SEGMENT } from '../../graphql/queries';

const previewMock = {
  request: {
    query: PREVIEW_GOLFER_SEGMENT,
    variables: { filterCriteria: { booking_count_min: 5 } },
  },
  result: {
    data: {
      golferSegmentPreview: {
        count: 23,
        sample: [
          { id: '1', name: 'John Smith', email: 'john@example.com' },
          { id: '2', name: 'Jane Doe', email: 'jane@example.com' },
          { id: '3', name: 'Bob Wilson', email: 'bob@example.com' },
        ],
      },
    },
  },
};

const meta: Meta<typeof SegmentFilterBuilder> = {
  title: 'Segments/SegmentFilterBuilder',
  component: SegmentFilterBuilder,
  tags: ['autodocs'],
  decorators: [
    (Story: React.ComponentType) => (
      <MockedProvider mocks={[previewMock]} addTypename={false}>
        <div className="max-w-2xl p-6">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof SegmentFilterBuilder>;

export const Empty: Story = {
  args: {
    value: {},
    onChange: () => {},
  },
};

export const WithBookingFilter: Story = {
  args: {
    value: { booking_count_min: 5 },
    onChange: () => {},
  },
};

export const WithMultipleFilters: Story = {
  args: {
    value: {
      booking_count_min: 3,
      membership_status: 'active',
      total_spent_min: 50000,
      last_booking_within_days: 60,
    },
    onChange: () => {},
  },
};

export const WithMembershipTiers: Story = {
  args: {
    value: {
      membership_tier: ['gold', 'platinum'],
      membership_status: 'active',
    },
    onChange: () => {},
  },
};
