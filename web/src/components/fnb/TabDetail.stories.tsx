import type { Meta, StoryObj } from '@storybook/react';
import { TabDetail } from './TabDetail';
import type { FnbTabDetailData } from './TabDetail';

const meta: Meta<typeof TabDetail> = {
  title: 'FnB/TabDetail',
  component: TabDetail,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof TabDetail>;

const openTabWithItems: FnbTabDetailData = {
  id: '1',
  golferName: 'Mike Johnson',
  status: 'open',
  totalCents: 4250,
  openedAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
  itemCount: 4,
  canBeModified: true,
  durationInMinutes: 45,
  course: { name: 'Pine Valley Golf Club' },
  user: { fullName: 'Sarah behind the bar' },
  fnbTabItems: [
    {
      id: 'item-1',
      name: 'Cheeseburger',
      quantity: 1,
      unitPriceCents: 1250,
      totalCents: 1250,
      category: 'food',
      notes: 'No onions',
      addedBy: { fullName: 'Sarah behind the bar' },
      createdAt: new Date(Date.now() - 40 * 60 * 1000).toISOString(),
    },
    {
      id: 'item-2',
      name: 'Draft IPA',
      quantity: 2,
      unitPriceCents: 800,
      totalCents: 1600,
      category: 'beverage',
      addedBy: { fullName: 'Sarah behind the bar' },
      createdAt: new Date(Date.now() - 35 * 60 * 1000).toISOString(),
    },
    {
      id: 'item-3',
      name: 'Hot Dog',
      quantity: 1,
      unitPriceCents: 650,
      totalCents: 650,
      category: 'food',
      addedBy: { fullName: 'Jake at the turn' },
      createdAt: new Date(Date.now() - 20 * 60 * 1000).toISOString(),
    },
    {
      id: 'item-4',
      name: 'Gatorade',
      quantity: 1,
      unitPriceCents: 750,
      totalCents: 750,
      category: 'beverage',
      addedBy: { fullName: 'Jake at the turn' },
      createdAt: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    },
  ],
};

const defaultHandlers = {
  onAddItem: () => console.log('Add item'),
  onRemoveItem: (itemId: string) => console.log('Remove item:', itemId),
  onCloseTab: () => console.log('Close tab'),
  onBack: () => console.log('Go back'),
};

export const OpenWithItems: Story = {
  args: {
    tab: openTabWithItems,
    ...defaultHandlers,
  },
};

export const EmptyTab: Story = {
  args: {
    tab: {
      ...openTabWithItems,
      totalCents: 0,
      itemCount: 0,
      fnbTabItems: [],
    },
    ...defaultHandlers,
  },
};

export const ClosedTab: Story = {
  args: {
    tab: {
      ...openTabWithItems,
      status: 'closed',
      closedAt: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
      canBeModified: false,
      durationInMinutes: 120,
    },
    ...defaultHandlers,
  },
};

export const MergedTab: Story = {
  args: {
    tab: {
      ...openTabWithItems,
      status: 'merged',
      canBeModified: false,
      golferName: 'Chris Anderson',
      durationInMinutes: 90,
    },
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    tab: openTabWithItems,
    loading: true,
    ...defaultHandlers,
  },
};
