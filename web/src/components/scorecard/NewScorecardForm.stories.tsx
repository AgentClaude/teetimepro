import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider } from '@apollo/client/testing';
import { NewScorecardForm } from './NewScorecardForm';
import { GET_COURSES } from '../../graphql/queries';

const meta: Meta<typeof NewScorecardForm> = {
  title: 'Scorecard/NewScorecardForm',
  component: NewScorecardForm,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof NewScorecardForm>;

const mockCourses = [
  { id: 'c-1', name: 'Pine Valley Golf Club' },
  { id: 'c-2', name: 'Augusta National' },
  { id: 'c-3', name: 'Pebble Beach Golf Links' },
];

const coursesMock = {
  request: { query: GET_COURSES },
  result: { data: { courses: mockCourses } },
};

const emptyCourseMock = {
  request: { query: GET_COURSES },
  result: { data: { courses: [] } },
};

export const Default: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[coursesMock]} addTypename={false}>
        <div className="max-w-lg mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    golferProfileId: 'gp-1',
    onCreated: (id: string) => console.log('Created scorecard:', id),
    onCancel: () => console.log('Cancelled'),
  },
};

export const WithBooking: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[coursesMock]} addTypename={false}>
        <div className="max-w-lg mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    golferProfileId: 'gp-1',
    bookingId: 'booking-123',
    onCreated: (id: string) => console.log('Created scorecard:', id),
    onCancel: () => console.log('Cancelled'),
  },
};

export const NoCourses: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[emptyCourseMock]} addTypename={false}>
        <div className="max-w-lg mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    golferProfileId: 'gp-1',
  },
};

export const WithoutCancel: Story = {
  decorators: [
    (Story) => (
      <MockedProvider mocks={[coursesMock]} addTypename={false}>
        <div className="max-w-lg mx-auto p-4">
          <Story />
        </div>
      </MockedProvider>
    ),
  ],
  args: {
    golferProfileId: 'gp-1',
    onCreated: (id: string) => console.log('Created scorecard:', id),
  },
};
