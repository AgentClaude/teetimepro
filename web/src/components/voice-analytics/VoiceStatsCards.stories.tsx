import type { Meta, StoryObj } from '@storybook/react';
import { VoiceStatsCards } from './VoiceStatsCards';

const meta: Meta<typeof VoiceStatsCards> = {
  title: 'Voice Analytics/VoiceStatsCards',
  component: VoiceStatsCards,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof VoiceStatsCards>;

const mockAnalytics = {
  totalCalls: 1234,
  completedCalls: 980,
  errorRate: 8.5,
  averageDurationSeconds: 127, // 2:07
  bookingConversionRate: 23.4,
};

const mockHighVolumeAnalytics = {
  totalCalls: 5678,
  completedCalls: 5234,
  errorRate: 2.1,
  averageDurationSeconds: 245, // 4:05
  bookingConversionRate: 31.2,
};

const mockLowPerformanceAnalytics = {
  totalCalls: 156,
  completedCalls: 98,
  errorRate: 18.7,
  averageDurationSeconds: 89, // 1:29
  bookingConversionRate: 7.8,
};

const mockZeroAnalytics = {
  totalCalls: 0,
  completedCalls: 0,
  errorRate: 0,
  averageDurationSeconds: 0,
  bookingConversionRate: 0,
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

export const LowPerformance: Story = {
  args: {
    analytics: mockLowPerformanceAnalytics,
  },
};

export const NoData: Story = {
  args: {
    analytics: mockZeroAnalytics,
  },
};

export const HighErrorRate: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      errorRate: 15.6,
    },
  },
};

export const MediumErrorRate: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      errorRate: 7.3,
    },
  },
};

export const LowErrorRate: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      errorRate: 1.2,
    },
  },
};

export const HighConversion: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      bookingConversionRate: 45.8,
    },
  },
};

export const LowConversion: Story = {
  args: {
    analytics: {
      ...mockAnalytics,
      bookingConversionRate: 5.2,
    },
  },
};