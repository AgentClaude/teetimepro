import type { Meta, StoryObj } from '@storybook/react';
import { DownloadIcsButton, BookingCalendarDownload } from '../components/calendar/DownloadIcsButton';

const mockBooking = {
  id: '123',
  confirmationCode: 'ABC123',
  startsAt: '2024-03-10T14:30:00Z',
  course: {
    name: 'Pebble Beach Golf Links',
    address: '1700 17-Mile Drive',
    city: 'Pebble Beach',
    state: 'CA',
    zipCode: '93953'
  },
  playersCount: 4,
  notes: 'Birthday celebration round',
  bookingPlayers: [
    { name: 'John Smith' },
    { name: 'Jane Doe' },
    { name: 'Bob Johnson' },
    { name: 'Alice Brown' }
  ]
};

const meta: Meta<typeof DownloadIcsButton> = {
  title: 'Calendar/DownloadIcsButton',
  component: DownloadIcsButton,
  tags: ['autodocs'],
  parameters: {
    docs: {
      description: {
        component: 'A button component for downloading ICS calendar files for golf bookings.'
      }
    }
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'outline', 'ghost'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    showText: {
      control: 'boolean',
    }
  },
};

export default meta;
type Story = StoryObj<typeof DownloadIcsButton>;

export const Default: Story = {
  args: {
    booking: mockBooking,
    variant: 'outline',
    size: 'md',
    showText: true,
  },
};

export const IconOnly: Story = {
  args: {
    booking: mockBooking,
    variant: 'ghost',
    size: 'sm',
    showText: false,
  },
};

export const Large: Story = {
  args: {
    booking: mockBooking,
    variant: 'default',
    size: 'lg',
    showText: true,
  },
};

export const BookingCalendarDownloadExample: StoryObj<typeof BookingCalendarDownload> = {
  render: () => (
    <div className="max-w-md">
      <BookingCalendarDownload booking={mockBooking} />
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'The full booking calendar download component with explanatory text.'
      }
    }
  }
};