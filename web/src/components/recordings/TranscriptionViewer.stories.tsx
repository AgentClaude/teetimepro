import type { Meta, StoryObj } from '@storybook/react';
import { TranscriptionViewer } from './TranscriptionViewer';
import type { CallRecording, CallTranscription } from '../../types';

const meta: Meta<typeof TranscriptionViewer> = {
  title: 'Recordings/TranscriptionViewer',
  component: TranscriptionViewer,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof TranscriptionViewer>;

const mockRecording: CallRecording = {
  id: 'rec-1',
  organizationId: 'org-1',
  callSid: 'CA1234567890abcdef',
  recordingSid: 'RE1234567890abcdef',
  recordingUrl: 'https://api.twilio.com/recordings/sample.wav',
  durationSeconds: 185,
  status: 'completed',
  fileSizeBytes: 2048000,
  format: 'wav',
  transcribed: true,
  callTranscriptions: [],
  formattedDuration: '3:05',
  createdAt: '2024-01-20T14:30:00Z',
  updatedAt: '2024-01-20T14:30:00Z',
};

const mockHighConfidenceTranscription: CallTranscription = {
  id: 'trans-1',
  organizationId: 'org-1',
  callRecording: mockRecording,
  transcriptionText: `Hello, thank you for calling TeeTimes Pro Golf Course. My name is Sarah, how can I help you today?

Hi Sarah, I'd like to make a tee time reservation for this coming Saturday morning if possible.

Of course! I'd be happy to help you with that. What time were you looking for and how many players will be in your group?

We have four players and we were hoping for something around nine o'clock in the morning.

Let me check our availability for Saturday morning. I have a tee time available at nine fifteen AM for four players. Would that work for your group?

Yes, that sounds perfect! Let me go ahead and book that for you.

Great! I'll need to get some information from you. Can I start with the name for the reservation?

Yes, it's John Smith. That's S-M-I-T-H.

Perfect, John Smith. And what's the best phone number to reach you at?

You can reach me at five five five, one two three, four five six seven.

Excellent. Your tee time is confirmed for Saturday, January twenty-second at nine fifteen AM for four players under the name John Smith. The total will be two hundred and forty dollars. Would you like to pay now or when you arrive?

I'll pay when we arrive. Thank you so much!

You're very welcome! We'll see you Saturday morning at nine fifteen. Have a great day!`,
  confidenceScore: 0.92,
  language: 'en',
  provider: 'deepgram',
  status: 'completed',
  wordCount: 197,
  durationSeconds: 185,
  highConfidence: true,
  mediumConfidence: false,
  lowConfidence: false,
  formattedDuration: '3:05',
  rawResponse: {
    results: {
      channels: [
        {
          alternatives: [
            {
              transcript: 'Hello, thank you for calling TeeTimes Pro...',
              confidence: 0.92,
              words: [
                { word: 'hello', start: 0.48, end: 0.8, confidence: 0.99 },
                { word: 'thank', start: 1.0, end: 1.24, confidence: 0.95 },
                { word: 'you', start: 1.24, end: 1.36, confidence: 0.98 },
              ],
            },
          ],
        },
      ],
    },
    metadata: {
      request_id: '12345678-1234-1234-1234-123456789012',
      transaction_key: 'deprecated',
      sha256: 'abc123def456',
      created: '2024-01-20T14:30:00Z',
      duration: 185,
      channels: 1,
    },
  },
  createdAt: '2024-01-20T14:30:05Z',
  updatedAt: '2024-01-20T14:30:10Z',
};

const mockMediumConfidenceTranscription: CallTranscription = {
  ...mockHighConfidenceTranscription,
  transcriptionText: `Hello, thank you for calling TeeTimes Pro... I'd like to make a tee time but the connection is a bit unclear... can you repeat that... sorry about the background noise... yes that works for Saturday morning... perfect thanks!`,
  confidenceScore: 0.73,
  highConfidence: false,
  mediumConfidence: true,
  lowConfidence: false,
  wordCount: 42,
};

const mockLowConfidenceTranscription: CallTranscription = {
  ...mockHighConfidenceTranscription,
  transcriptionText: `[unclear audio] ... tee time ... Saturday ... [static] ... four players ... [unclear] ... thank you ...`,
  confidenceScore: 0.35,
  highConfidence: false,
  mediumConfidence: false,
  lowConfidence: true,
  wordCount: 15,
};

const mockShortTranscription: CallTranscription = {
  ...mockHighConfidenceTranscription,
  transcriptionText: `Hello, TeeTimes Pro.`,
  confidenceScore: 0.98,
  wordCount: 3,
  durationSeconds: 5,
  formattedDuration: '0:05',
};

const mockWhisperTranscription: CallTranscription = {
  ...mockHighConfidenceTranscription,
  provider: 'whisper',
};

const defaultHandlers = {
  onCopyToClipboard: (text: string) => {
    navigator.clipboard.writeText(text);
    console.log('Copied to clipboard:', text.substring(0, 50) + '...');
  },
  onDownloadTranscript: (transcription: CallTranscription) => console.log('Download transcript:', transcription.id),
  onPlayRecording: (recording: CallRecording) => console.log('Play recording:', recording.id),
};

export const HighConfidence: Story = {
  args: {
    recording: mockRecording,
    transcription: mockHighConfidenceTranscription,
    loading: false,
    ...defaultHandlers,
  },
};

export const MediumConfidence: Story = {
  args: {
    recording: mockRecording,
    transcription: mockMediumConfidenceTranscription,
    loading: false,
    ...defaultHandlers,
  },
};

export const LowConfidence: Story = {
  args: {
    recording: mockRecording,
    transcription: mockLowConfidenceTranscription,
    loading: false,
    ...defaultHandlers,
  },
};

export const ShortTranscript: Story = {
  args: {
    recording: { ...mockRecording, durationSeconds: 5, formattedDuration: '0:05' },
    transcription: mockShortTranscription,
    loading: false,
    ...defaultHandlers,
  },
};

export const WhisperProvider: Story = {
  args: {
    recording: mockRecording,
    transcription: mockWhisperTranscription,
    loading: false,
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    recording: mockRecording,
    transcription: mockHighConfidenceTranscription,
    loading: true,
    ...defaultHandlers,
  },
};

export const WithoutPlayButton: Story = {
  args: {
    recording: mockRecording,
    transcription: mockHighConfidenceTranscription,
    loading: false,
    onCopyToClipboard: defaultHandlers.onCopyToClipboard,
    onDownloadTranscript: defaultHandlers.onDownloadTranscript,
    // No onPlayRecording handler
  },
};

export const ProcessingStatus: Story = {
  args: {
    recording: mockRecording,
    transcription: {
      ...mockHighConfidenceTranscription,
      status: 'processing',
      transcriptionText: '',
      confidenceScore: 0,
      wordCount: 0,
    },
    loading: false,
    ...defaultHandlers,
  },
};

export const EmptyTranscript: Story = {
  args: {
    recording: mockRecording,
    transcription: {
      ...mockHighConfidenceTranscription,
      transcriptionText: '',
      wordCount: 0,
    },
    loading: false,
    ...defaultHandlers,
  },
};

export const LongTranscript: Story = {
  args: {
    recording: { ...mockRecording, durationSeconds: 1200, formattedDuration: '20:00' },
    transcription: {
      ...mockHighConfidenceTranscription,
      transcriptionText: Array.from({ length: 50 }, () => mockHighConfidenceTranscription.transcriptionText).join('\n\n'),
      wordCount: 9850,
      durationSeconds: 1200,
      formattedDuration: '20:00',
    },
    loading: false,
    ...defaultHandlers,
  },
};