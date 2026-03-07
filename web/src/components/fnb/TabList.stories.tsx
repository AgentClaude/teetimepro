import type { Meta, StoryObj } from '@storybook/react';
import { TabList } from './TabList';
import type { FnbTab } from './TabList';

const meta: Meta<typeof TabList> = {
  title: 'FnB/TabList',
  component: TabList,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof TabList>;

const mockTabs: FnbTab[] = [
  {
    id: '1',
    golferName: 'Mike Johnson',
    status: 'open',
    totalCents: 4250,
    openedAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    itemCount: 4,
    canBeModified: true,
    course: { name: 'Pine Valley Golf Club' },
    user: { fullName: 'Sarah behind the bar' },
  },
  {
    id: '2',
    golferName: 'Dave Williams',
    status: 'open',
    totalCents: 2800,
    openedAt: new Date(Date.now() - 120 * 60 * 1000).toISOString(),
    itemCount: 3,
    canBeModified: true,
    course: { name: 'Pine Valley Golf Club' },
    user: { fullName: 'Sarah behind the bar' },
  },
  {
    id: '3',
    golferName: 'Tom Bradley',
    status: 'closed',
    totalCents: 6100,
    openedAt: new Date(Date.now() - 240 * 60 * 1000).toISOString(),
    closedAt: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
    itemCount: 6,
    canBeModified: false,
    course: { name: 'Oakmont Country Club' },
    user: { fullName: 'Jake at the turn' },
  },
  {
    id: '4',
    golferName: 'Chris Anderson',
    status: 'merged',
    totalCents: 1500,
    openedAt: new Date(Date.now() - 180 * 60 * 1000).toISOString(),
    itemCount: 2,
    canBeModified: false,
    course: { name: 'Pine Valley Golf Club' },
    user: { fullName: 'Sarah behind the bar' },
  },
];

const defaultHandlers = {
  onOpenTab: () => console.log('Open tab'),
  onViewTab: (id: string) => console.log('View tab:', id),
  onCloseTab: (id: string) => console.log('Close tab:', id),
};

export const Default: Story = {
  args: {
    tabs: mockTabs,
    ...defaultHandlers,
  },
};

export const EmptyState: Story = {
  args: {
    tabs: [],
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    tabs: [],
    loading: true,
    ...defaultHandlers,
  },
};

export const SingleTab: Story = {
  args: {
    tabs: [mockTabs[0]],
    ...defaultHandlers,
  },
};

export const AllClosed: Story = {
  args: {
    tabs: [
      {
        id: '10',
        golferName: 'Bill Murray',
        status: 'closed',
        totalCents: 8750,
        openedAt: new Date(Date.now() - 360 * 60 * 1000).toISOString(),
        closedAt: new Date(Date.now() - 60 * 60 * 1000).toISOString(),
        itemCount: 8,
        canBeModified: false,
        course: { name: 'Bushwood Country Club' },
        user: { fullName: 'Danny Noonan' },
      },
      {
        id: '11',
        golferName: 'Carl Spackler',
        status: 'closed',
        totalCents: 3200,
        openedAt: new Date(Date.now() - 300 * 60 * 1000).toISOString(),
        closedAt: new Date(Date.now() - 90 * 60 * 1000).toISOString(),
        itemCount: 3,
        canBeModified: false,
        course: { name: 'Bushwood Country Club' },
        user: { fullName: 'Danny Noonan' },
      },
    ],
    ...defaultHandlers,
  },
};
