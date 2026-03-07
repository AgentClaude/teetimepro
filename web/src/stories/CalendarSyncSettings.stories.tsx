import type { Meta, StoryObj } from '@storybook/react';
import { CalendarSyncSettings } from '../components/calendar/CalendarSyncSettings';

const mockConnections = [
  {
    id: '1',
    provider: 'google' as const,
    enabled: true,
    calendarName: 'Personal Calendar',
    createdAt: '2024-03-01T10:00:00Z'
  }
];

const mockActions = {
  onConnect: async (provider: 'google' | 'apple') => {
    console.log('Connect:', provider);
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
  },
  onDisconnect: async (provider: 'google' | 'apple') => {
    console.log('Disconnect:', provider);
    await new Promise(resolve => setTimeout(resolve, 1000));
  },
  onToggle: async (provider: 'google' | 'apple', enabled: boolean) => {
    console.log('Toggle:', provider, enabled);
    await new Promise(resolve => setTimeout(resolve, 500));
  }
};

const meta: Meta<typeof CalendarSyncSettings> = {
  title: 'Calendar/CalendarSyncSettings',
  component: CalendarSyncSettings,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'Settings component for managing calendar sync connections and preferences.'
      }
    },
    layout: 'padded'
  },
};

export default meta;
type Story = StoryObj<typeof CalendarSyncSettings>;

export const NoConnections: Story = {
  args: {
    connections: [],
    ...mockActions
  },
  parameters: {
    docs: {
      description: {
        story: 'Initial state with no calendar connections configured.'
      }
    }
  }
};

export const GoogleConnected: Story = {
  args: {
    connections: mockConnections,
    ...mockActions
  },
  parameters: {
    docs: {
      description: {
        story: 'State with Google Calendar connected and enabled.'
      }
    }
  }
};

export const GoogleConnectedDisabled: Story = {
  args: {
    connections: [
      {
        ...mockConnections[0],
        enabled: false
      }
    ],
    ...mockActions
  },
  parameters: {
    docs: {
      description: {
        story: 'State with Google Calendar connected but disabled.'
      }
    }
  }
};

export const BothConnected: Story = {
  args: {
    connections: [
      ...mockConnections,
      {
        id: '2',
        provider: 'apple' as const,
        enabled: true,
        calendarName: 'iCloud Calendar',
        createdAt: '2024-03-02T10:00:00Z'
      }
    ],
    ...mockActions
  },
  parameters: {
    docs: {
      description: {
        story: 'State with both Google and Apple Calendar connected (note: Apple is coming soon).'
      }
    }
  }
};