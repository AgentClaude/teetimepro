import type { Meta, StoryObj } from '@storybook/react';
import { OpenTabDialog } from './OpenTabDialog';

const meta: Meta<typeof OpenTabDialog> = {
  title: 'FnB/OpenTabDialog',
  component: OpenTabDialog,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof OpenTabDialog>;

const mockCourses = [
  { id: 'course-1', name: 'Pine Valley Golf Club' },
  { id: 'course-2', name: 'Oakmont Country Club' },
  { id: 'course-3', name: 'Augusta National' },
];

const defaultHandlers = {
  onClose: () => console.log('Close dialog'),
  onSubmit: (data: { golferName: string; courseId: string }) =>
    console.log('Open tab:', data),
};

export const Default: Story = {
  args: {
    isOpen: true,
    courses: mockCourses,
    ...defaultHandlers,
  },
};

export const Loading: Story = {
  args: {
    isOpen: true,
    courses: mockCourses,
    loading: true,
    ...defaultHandlers,
  },
};

export const NoCourses: Story = {
  args: {
    isOpen: true,
    courses: [],
    ...defaultHandlers,
  },
};
