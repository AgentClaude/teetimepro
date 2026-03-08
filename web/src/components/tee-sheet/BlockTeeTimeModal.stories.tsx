import type { Meta, StoryObj } from '@storybook/react';
import { BlockTeeTimeModal } from './BlockTeeTimeModal';

const meta: Meta<typeof BlockTeeTimeModal> = {
  title: 'TeeSheet/BlockTeeTimeModal',
  component: BlockTeeTimeModal,
  parameters: {
    layout: 'centered',
  },
  decorators: [
    (Story) => (
      <div style={{ width: '100vw', height: '100vh' }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof BlockTeeTimeModal>;

export const Default: Story = {
  args: {
    courseId: '1',
    courseName: 'Pebble Beach Golf Links',
    isOpen: true,
    onClose: () => console.log('Close'),
    onSubmit: (data) => console.log('Submit', data),
  },
};

export const Loading: Story = {
  args: {
    ...Default.args,
    isLoading: true,
  },
};

export const WithError: Story = {
  args: {
    ...Default.args,
    error: 'Overlapping block already exists for this time range',
  },
};

export const Closed: Story = {
  args: {
    ...Default.args,
    isOpen: false,
  },
};
