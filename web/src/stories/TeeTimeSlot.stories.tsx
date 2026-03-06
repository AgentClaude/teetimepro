import type { Meta, StoryObj } from '@storybook/react';
import { TeeTimeSlot, type TeeTimeData } from '../components/tee-sheet/TeeTimeSlot';

const meta: Meta<typeof TeeTimeSlot> = {
  title: 'TeeSheet/TeeTimeSlot',
  component: TeeTimeSlot,
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="mx-auto max-w-4xl rounded-lg bg-white shadow">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof TeeTimeSlot>;

const baseTeeTime: TeeTimeData = {
  id: '1',
  startsAt: '2026-03-06T07:00:00Z',
  maxPlayers: 4,
  bookedPlayers: 0,
  status: 'AVAILABLE',
  priceCents: 5500,
};

export const Available: Story = {
  args: {
    teeTime: { ...baseTeeTime },
  },
};

export const PartiallyBooked: Story = {
  args: {
    teeTime: {
      ...baseTeeTime,
      bookedPlayers: 2,
      status: 'PARTIALLY_BOOKED',
      bookings: [
        {
          id: 'b1',
          confirmationCode: 'TTP-A1B2C3',
          playersCount: 2,
          user: { fullName: 'John Smith' },
        },
      ],
    },
  },
};

export const FullyBooked: Story = {
  args: {
    teeTime: {
      ...baseTeeTime,
      bookedPlayers: 4,
      status: 'FULLY_BOOKED',
      bookings: [
        {
          id: 'b1',
          confirmationCode: 'TTP-X9Y8Z7',
          playersCount: 4,
          user: { fullName: 'Mike Johnson' },
        },
      ],
    },
  },
};

export const Blocked: Story = {
  args: {
    teeTime: {
      ...baseTeeTime,
      status: 'BLOCKED',
      priceCents: null,
    },
  },
};

export const Maintenance: Story = {
  args: {
    teeTime: {
      ...baseTeeTime,
      status: 'MAINTENANCE',
      priceCents: null,
    },
  },
};

export const PremiumRate: Story = {
  args: {
    teeTime: {
      ...baseTeeTime,
      startsAt: '2026-03-07T09:00:00Z', // Saturday morning
      priceCents: 8500,
    },
  },
};
