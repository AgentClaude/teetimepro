import type { Meta, StoryObj } from '@storybook/react';
import { RecordingsList } from './RecordingsList';
import type { CallRecording } from '../../types';

const meta: Meta<typeof RecordingsList> = {
  title: 'Recordings/RecordingsList',
  component: RecordingsList,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof RecordingsList>;

const mockTranscription = {
  id: 'trans-1',
  organizationId: 'org-1',
  transcriptionText: 'Hello, thank you for calling TeeTimes Pro. How can I help you today?',
  confidenceScore: 0.85,
  language: 'en',
  provider: 'deepgram',
  status: 'completed' as const,
  wordCount: 12,
  durationSeconds: 45,
  highConfidence: true,
  mediumConfidence: false,
  lowConfidence: false,
  formattedDuration: '0:45',
  createdAt: '2024-01-20T14:30:00Z',
  updatedAt: '2024-01-20T14:30:05Z',
};

const mockRecordings: CallRecording[] = [
  {
    id: 'rec-1',
    organizationId: 'org-1',
    callSid: 'CA1234567890abcdef',
    recordingSid: 'RE1234567890abcdef',
    recordingUrl: 'https://api.twilio.com/recordings/sample1.wav',
    durationSeconds: 120,
    status: 'completed',
    fileSizeBytes: 2048000,
    format: 'wav',
    transcribed: true,
    latestTranscription: mockTranscription,
    callTranscriptions: [mockTranscription],
    formattedDuration: '2:00',
    createdAt: '2024-01-20T14:30:00Z',
    updatedAt: '2024-01-20T14:30:00Z',
  },
  {
    id: 'rec-2',
    organizationId: 'org-1',
    callSid: 'CA2345678901bcdefg',
    recordingSid: 'RE2345678901bcdefg',
    recordingUrl: 'https://api.twilio.com/recordings/sample2.wav',
    durationSeconds: 75,
    status: 'completed',
    fileSizeBytes: 1536000,
    format: 'wav',
    transcribed: false,
    callTranscriptions: [],
    formattedDuration: '1:15',
    createdAt: '2024-01-20T13:15:00Z',
    updatedAt: '2024-01-20T13:15:00Z',
  },
  {
    id: 'rec-3',
    organizationId: 'org-1',
    callSid: 'CA3456789012cdefgh',
    recordingSid: 'RE3456789012cdefgh',
    recordingUrl: 'https://api.twilio.com/recordings/sample3.wav',
    durationSeconds: 180,
    status: 'processing',
    fileSizeBytes: 3072000,
    format: 'wav',
    transcribed: false,
    callTranscriptions: [],
    formattedDuration: '3:00',
    createdAt: '2024-01-20T12:45:00Z',
    updatedAt: '2024-01-20T12:45:00Z',
  },
  {
    id: 'rec-4',
    organizationId: 'org-1',
    callSid: 'CA4567890123defghi',
    recordingSid: 'RE4567890123defghi',
    recordingUrl: 'https://api.twilio.com/recordings/sample4.wav',
    durationSeconds: 45,
    status: 'failed',
    fileSizeBytes: 1024000,
    format: 'wav',
    transcribed: false,
    callTranscriptions: [],
    formattedDuration: '0:45',
    createdAt: '2024-01-20T11:30:00Z',
    updatedAt: '2024-01-20T11:30:00Z',
  },
];

const defaultHandlers = {
  onSearch: (query: string) => console.log('Search:', query),
  onFilterStatus: (status: string) => console.log('Filter status:', status),
  onFilterDateRange: (dateFrom: string, dateTo: string) => console.log('Filter date range:', dateFrom, dateTo),
  onPageChange: (page: number) => console.log('Page change:', page),
  onPlayRecording: (recording: CallRecording) => console.log('Play recording:', recording.id),
  onViewTranscription: (recording: CallRecording) => console.log('View transcription:', recording.id),
  onRequestTranscription: (recording: CallRecording) => console.log('Request transcription:', recording.id),
};

export const Default: Story = {
  args: {
    recordings: mockRecordings,
    loading: false,
    totalCount: 4,
    currentPage: 1,
    totalPages: 1,
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    recordings: [],
    loading: true,
    totalCount: 0,
    currentPage: 1,
    totalPages: 0,
    ...defaultHandlers,
  },
};

export const EmptyState: Story = {
  args: {
    recordings: [],
    loading: false,
    totalCount: 0,
    currentPage: 1,
    totalPages: 0,
    ...defaultHandlers,
  },
};

export const SinglePage: Story = {
  args: {
    recordings: mockRecordings.slice(0, 2),
    loading: false,
    totalCount: 2,
    currentPage: 1,
    totalPages: 1,
    ...defaultHandlers,
  },
};

export const Paginated: Story = {
  args: {
    recordings: mockRecordings,
    loading: false,
    totalCount: 25,
    currentPage: 2,
    totalPages: 3,
    ...defaultHandlers,
  },
};

export const LowConfidenceTranscription: Story = {
  args: {
    recordings: [
      {
        ...mockRecordings[0],
        latestTranscription: {
          ...mockTranscription,
          confidenceScore: 0.45,
          highConfidence: false,
          mediumConfidence: false,
          lowConfidence: true,
        },
      },
    ],
    loading: false,
    totalCount: 1,
    currentPage: 1,
    totalPages: 1,
    ...defaultHandlers,
  },
};

export const MixedStatuses: Story = {
  args: {
    recordings: mockRecordings,
    loading: false,
    totalCount: 4,
    currentPage: 1,
    totalPages: 1,
    ...defaultHandlers,
  },
};

export const LargeDataset: Story = {
  args: {
    recordings: Array.from({ length: 20 }, (_, i) => ({
      ...mockRecordings[i % mockRecordings.length],
      id: `rec-${i + 1}`,
      callSid: `CA${i.toString().padStart(16, '0')}`,
      recordingSid: `RE${i.toString().padStart(16, '0')}`,
      createdAt: new Date(Date.now() - i * 3600000).toISOString(),
    })),
    loading: false,
    totalCount: 127,
    currentPage: 1,
    totalPages: 7,
    ...defaultHandlers,
  },
};