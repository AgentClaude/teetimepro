import type { Meta, StoryObj } from '@storybook/react';
import { VoiceAnalyticsCharts } from './VoiceAnalyticsCharts';

const meta: Meta<typeof VoiceAnalyticsCharts> = {
  title: 'Voice Analytics/VoiceAnalyticsCharts',
  component: VoiceAnalyticsCharts,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof VoiceAnalyticsCharts>;

// Generate sample daily data for the last 30 days
const generateDailyData = (days: number, baseCount: number = 10, variance: number = 5) => {
  const data = [];
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    const randomVariance = Math.floor(Math.random() * variance * 2) - variance;
    data.push({
      date: date.toISOString().split('T')[0],
      count: Math.max(0, baseCount + randomVariance),
    });
  }
  return data;
};

const mockAnalytics = {
  callsByChannel: [
    { channel: 'browser', count: 145 },
    { channel: 'twilio', count: 89 },
  ],
  callsByDay: generateDailyData(30, 12, 6),
  topCallers: [
    { phone: '+1234567890', name: 'John Smith', totalCalls: 15, averageDurationSeconds: 180 },
    { phone: '+1987654321', name: 'Jane Doe', totalCalls: 12, averageDurationSeconds: 145 },
    { phone: '+1555123456', name: 'Mike Johnson', totalCalls: 10, averageDurationSeconds: 203 },
    { phone: '+1444555666', name: 'Sarah Wilson', totalCalls: 8, averageDurationSeconds: 167 },
    { phone: '+1777888999', name: 'Bob Brown', totalCalls: 7, averageDurationSeconds: 192 },
    { phone: '+1333444555', name: 'Lisa Davis', totalCalls: 6, averageDurationSeconds: 156 },
    { phone: '+1666777888', name: 'Tom Miller', totalCalls: 5, averageDurationSeconds: 201 },
    { phone: '+1222333444', name: 'Emily Taylor', totalCalls: 4, averageDurationSeconds: 134 },
  ],
};

const mockHighVolumeAnalytics = {
  callsByChannel: [
    { channel: 'browser', count: 567 },
    { channel: 'twilio', count: 432 },
  ],
  callsByDay: generateDailyData(30, 45, 15),
  topCallers: [
    { phone: '+1234567890', name: 'John Smith', totalCalls: 45, averageDurationSeconds: 234 },
    { phone: '+1987654321', name: 'Jane Doe', totalCalls: 38, averageDurationSeconds: 187 },
    { phone: '+1555123456', name: 'Mike Johnson', totalCalls: 32, averageDurationSeconds: 203 },
    { phone: '+1444555666', name: 'Sarah Wilson', totalCalls: 28, averageDurationSeconds: 167 },
    { phone: '+1777888999', name: 'Bob Brown', totalCalls: 25, averageDurationSeconds: 192 },
    { phone: '+1333444555', name: 'Lisa Davis', totalCalls: 22, averageDurationSeconds: 156 },
    { phone: '+1666777888', name: 'Tom Miller', totalCalls: 19, averageDurationSeconds: 201 },
    { phone: '+1222333444', name: 'Emily Taylor', totalCalls: 16, averageDurationSeconds: 134 },
  ],
};

const mockBrowserOnlyAnalytics = {
  callsByChannel: [
    { channel: 'browser', count: 234 },
  ],
  callsByDay: generateDailyData(7, 8, 3),
  topCallers: [
    { phone: '+1234567890', name: 'John Smith', totalCalls: 8, averageDurationSeconds: 180 },
    { phone: '+1987654321', name: 'Jane Doe', totalCalls: 6, averageDurationSeconds: 145 },
    { phone: '+1555123456', name: 'Mike Johnson', totalCalls: 4, averageDurationSeconds: 203 },
  ],
};

const mockEmptyAnalytics = {
  callsByChannel: [],
  callsByDay: [],
  topCallers: [],
};

const mockUnknownCallersAnalytics = {
  callsByChannel: [
    { channel: 'browser', count: 67 },
    { channel: 'twilio', count: 123 },
  ],
  callsByDay: generateDailyData(14, 5, 2),
  topCallers: [
    { phone: '+1234567890', name: 'Unknown', totalCalls: 12, averageDurationSeconds: 98 },
    { phone: '+1987654321', name: 'Unknown', totalCalls: 8, averageDurationSeconds: 156 },
    { phone: '+1555123456', name: 'Bob Brown', totalCalls: 6, averageDurationSeconds: 201 },
  ],
};

export const Default: Story = {
  args: {
    analytics: mockAnalytics,
  },
};

export const HighVolume: Story = {
  args: {
    analytics: mockHighVolumeAnalytics,
  },
};

export const BrowserOnly: Story = {
  args: {
    analytics: mockBrowserOnlyAnalytics,
  },
};

export const NoData: Story = {
  args: {
    analytics: mockEmptyAnalytics,
  },
};

export const UnknownCallers: Story = {
  args: {
    analytics: mockUnknownCallersAnalytics,
  },
};

export const SevenDaysData: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      callsByDay: generateDailyData(7, 15, 8),
    },
  },
};

export const NinetyDaysData: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      callsByDay: generateDailyData(90, 8, 4),
    },
  },
};