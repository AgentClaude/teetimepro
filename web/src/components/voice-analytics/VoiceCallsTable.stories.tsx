import type { Meta, StoryObj } from '@storybook/react';
import { VoiceCallsTable } from './VoiceCallsTable';

const meta: Meta<typeof VoiceCallsTable> = {
  title: 'Voice Analytics/VoiceCallsTable',
  component: VoiceCallsTable,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof VoiceCallsTable>;

const generateMockCalls = (count: number) => {
  const statuses = ['completed', 'error', 'in_progress'];
  const channels = ['browser', 'twilio'];
  const courses = ['Pine Valley Golf Club', 'Oakmont Country Club', 'Augusta National'];
  const callers = [
    { name: 'John Smith', phone: '+1234567890' },
    { name: 'Jane Doe', phone: '+1987654321' },
    { name: 'Mike Johnson', phone: '+1555123456' },
    { name: 'Sarah Wilson', phone: '+1444555666' },
    { name: 'Bob Brown', phone: '+1777888999' },
    { name: 'Lisa Davis', phone: '+1333444555' },
    { name: null, phone: '+1666777888' }, // Unknown caller
    { name: 'Emily Taylor', phone: '+1222333444' },
  ];

  return Array.from({ length: count }, (_, i) => {
    const caller = callers[i % callers.length];
    const status = statuses[i % statuses.length];
    const channel = channels[i % channels.length];
    const course = courses[i % courses.length];
    
    const startDate = new Date();
    startDate.setHours(startDate.getHours() - (i * 2));
    
    const duration = status === 'completed' ? Math.floor(Math.random() * 300) + 60 : null;
    
    return {
      id: `call-${i + 1}`,
      courseId: `course-${(i % courses.length) + 1}`,
      courseName: course,
      channel,
      callerPhone: caller.phone,
      callerName: caller.name,
      status,
      durationSeconds: duration,
      startedAt: startDate.toISOString(),
      endedAt: status === 'completed' ? new Date(startDate.getTime() + (duration || 0) * 1000).toISOString() : undefined,
    };
  });
};

const mockCalls = generateMockCalls(15);
const mockLargeCalls = generateMockCalls(50);
const mockMinimalCalls = generateMockCalls(3);

export const Default: Story = {
  args: {
    calls: mockCalls,
    loading: false,
  },
};

export const Loading: Story = {
  args: {
    calls: [],
    loading: true,
  },
};

export const NoData: Story = {
  args: {
    calls: [],
    loading: false,
  },
};

export const LargeDdataset: Story = {
  args: {
    calls: mockLargeCalls,
    loading: false,
  },
};

export const MinimalData: Story = {
  args: {
    calls: mockMinimalCalls,
    loading: false,
  },
};

export const CompletedOnly: Story = {
  args: {
    calls: mockCalls.filter(call => call.status === 'completed'),
    loading: false,
  },
};

export const ErrorsOnly: Story = {
  args: {
    calls: mockCalls.filter(call => call.status === 'error'),
    loading: false,
  },
};

export const BrowserCallsOnly: Story = {
  args: {
    calls: mockCalls.filter(call => call.channel === 'browser'),
    loading: false,
  },
};

export const PhoneCallsOnly: Story = {
  args: {
    calls: mockCalls.filter(call => call.channel === 'twilio'),
    loading: false,
  },
};

export const UnknownCallers: Story = {
  args: {
    calls: mockCalls.map(call => ({
      ...call,
      callerName: null,
    })),
    loading: false,
  },
};

export const LongCalls: Story = {
  args: {
    calls: mockCalls.map(call => ({
      ...call,
      durationSeconds: call.status === 'completed' ? Math.floor(Math.random() * 600) + 300 : null,
    })),
    loading: false,
  },
};

export const ShortCalls: Story = {
  args: {
    calls: mockCalls.map(call => ({
      ...call,
      durationSeconds: call.status === 'completed' ? Math.floor(Math.random() * 60) + 10 : null,
    })),
    loading: false,
  },
};