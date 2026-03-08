import type { Meta, StoryObj } from '@storybook/react';
import { TeeTimeBlockList } from './TeeTimeBlockList';

const meta: Meta<typeof TeeTimeBlockList> = {
  title: 'TeeSheet/TeeTimeBlockList',
  component: TeeTimeBlockList,
  parameters: {
    layout: 'padded',
  },
};

export default meta;
type Story = StoryObj<typeof TeeTimeBlockList>;

const now = new Date();
const tomorrow = new Date(now.getTime() + 86400000);
const yesterday = new Date(now.getTime() - 86400000);

const mockBlocks = [
  {
    id: '1',
    blockType: 'maintenance',
    reason: 'Greens aeration',
    description: 'Scheduled aeration and reseeding of greens on holes 1-9',
    startsAt: new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate(), 6, 0).toISOString(),
    endsAt: new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate(), 10, 0).toISOString(),
    active: true,
    currentlyActive: false,
    affectedTeeTimeCount: 16,
    durationMinutes: 240,
    course: { id: '1', name: 'Pebble Beach Golf Links' },
    createdBy: { firstName: 'John', lastName: 'Smith' },
    createdAt: now.toISOString(),
  },
  {
    id: '2',
    blockType: 'event',
    reason: 'Club Championship - Day 1',
    description: 'Annual club championship tournament. Course closed to public play.',
    startsAt: new Date(now.getFullYear(), now.getMonth(), now.getDate(), 7, 0).toISOString(),
    endsAt: new Date(now.getFullYear(), now.getMonth(), now.getDate(), 17, 0).toISOString(),
    active: true,
    currentlyActive: true,
    affectedTeeTimeCount: 40,
    durationMinutes: 600,
    course: { id: '1', name: 'Pebble Beach Golf Links' },
    createdBy: { firstName: 'Jane', lastName: 'Doe' },
    createdAt: yesterday.toISOString(),
  },
  {
    id: '3',
    blockType: 'weather',
    reason: 'Lightning warning',
    description: 'Course closed due to severe thunderstorm warning',
    startsAt: new Date(now.getFullYear(), now.getMonth(), now.getDate(), 14, 0).toISOString(),
    endsAt: new Date(now.getFullYear(), now.getMonth(), now.getDate(), 18, 0).toISOString(),
    active: true,
    currentlyActive: true,
    affectedTeeTimeCount: 12,
    durationMinutes: 240,
    course: { id: '2', name: 'Spyglass Hill' },
    createdBy: { firstName: 'Bob', lastName: 'Wilson' },
    createdAt: now.toISOString(),
  },
];

export const Default: Story = {
  args: {
    blocks: mockBlocks,
    onUnblock: (id) => console.log('Unblock', id),
  },
};

export const Empty: Story = {
  args: {
    blocks: [],
    onUnblock: () => {},
  },
};

export const SingleBlock: Story = {
  args: {
    blocks: [mockBlocks[0]],
    onUnblock: (id) => console.log('Unblock', id),
  },
};

export const Unblocking: Story = {
  args: {
    blocks: mockBlocks,
    onUnblock: (id) => console.log('Unblock', id),
    isUnblocking: '2',
  },
};

export const WithInactiveBlock: Story = {
  args: {
    blocks: [
      ...mockBlocks,
      {
        id: '4',
        blockType: 'other',
        reason: 'Private rental (completed)',
        description: 'Course rented for corporate event',
        startsAt: yesterday.toISOString(),
        endsAt: now.toISOString(),
        active: false,
        currentlyActive: false,
        affectedTeeTimeCount: 24,
        durationMinutes: 480,
        course: { id: '1', name: 'Pebble Beach Golf Links' },
        createdBy: { firstName: 'Admin', lastName: 'User' },
        createdAt: yesterday.toISOString(),
      },
    ],
    onUnblock: (id) => console.log('Unblock', id),
  },
};
