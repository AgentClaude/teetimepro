import type { Meta, StoryObj } from '@storybook/react';
import { PrizeTable } from './PrizeTable';

const meta: Meta<typeof PrizeTable> = {
  title: 'Tournament/PrizeTable',
  component: PrizeTable,
  parameters: {
    layout: 'padded',
  },
  decorators: [
    (Story: React.ComponentType) => (
      <div className="max-w-4xl">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof PrizeTable>;

const mockPrizes = [
  {
    id: '1',
    position: 1,
    prizeType: 'Cash',
    description: 'First Place Winner',
    amountDisplay: '$500.00',
    awarded: true,
    awardedTo: {
      id: 'entry1',
      user: {
        id: 'user1',
        firstName: 'John',
        lastName: 'Smith',
      },
    },
  },
  {
    id: '2',
    position: 2,
    prizeType: 'Cash',
    description: 'Second Place',
    amountDisplay: '$250.00',
    awarded: true,
    awardedTo: {
      id: 'entry2',
      user: {
        id: 'user2',
        firstName: 'Sarah',
        lastName: 'Johnson',
      },
    },
  },
  {
    id: '3',
    position: 3,
    prizeType: 'Trophy',
    description: 'Third Place Trophy',
    amountDisplay: '$0.00',
    awarded: false,
  },
  {
    id: '4',
    position: 4,
    prizeType: 'Voucher',
    description: 'Pro Shop Voucher',
    amountDisplay: '$100.00',
    awarded: false,
  },
];

const largePrizePool = [
  {
    id: '1',
    position: 1,
    prizeType: 'Cash',
    description: 'Champion',
    amountDisplay: '$2,500.00',
    awarded: true,
    awardedTo: {
      id: 'entry1',
      user: {
        id: 'user1',
        firstName: 'Tiger',
        lastName: 'Woods',
      },
    },
  },
  {
    id: '2',
    position: 2,
    prizeType: 'Cash',
    description: 'Runner-up',
    amountDisplay: '$1,500.00',
    awarded: true,
    awardedTo: {
      id: 'entry2',
      user: {
        id: 'user2',
        firstName: 'Rory',
        lastName: 'McIlroy',
      },
    },
  },
  {
    id: '3',
    position: 3,
    prizeType: 'Cash',
    description: 'Third Place',
    amountDisplay: '$1,000.00',
    awarded: true,
    awardedTo: {
      id: 'entry3',
      user: {
        id: 'user3',
        firstName: 'Jordan',
        lastName: 'Spieth',
      },
    },
  },
  {
    id: '4',
    position: 4,
    prizeType: 'Cash',
    description: 'Fourth Place',
    amountDisplay: '$750.00',
    awarded: false,
  },
  {
    id: '5',
    position: 5,
    prizeType: 'Voucher',
    description: 'Fifth Place - Pro Shop Credit',
    amountDisplay: '$500.00',
    awarded: false,
  },
  {
    id: '6',
    position: 6,
    prizeType: 'Merchandise',
    description: 'Golf Equipment Package',
    amountDisplay: '$350.00',
    awarded: false,
  },
];

const mixedPrizes = [
  {
    id: '1',
    position: 1,
    prizeType: 'Cash',
    description: 'Overall Winner',
    amountDisplay: '$1,000.00',
    awarded: false,
  },
  {
    id: '2',
    position: 2,
    prizeType: 'Trophy',
    description: 'Crystal Trophy + Engraving',
    amountDisplay: '$0.00',
    awarded: false,
  },
  {
    id: '3',
    position: 3,
    prizeType: 'Voucher',
    description: 'Pro Shop Voucher',
    amountDisplay: '$200.00',
    awarded: false,
  },
  {
    id: '4',
    position: 4,
    prizeType: 'Merchandise',
    description: 'Golf Bag & Accessories',
    amountDisplay: '$300.00',
    awarded: false,
  },
  {
    id: '5',
    position: 5,
    prizeType: 'Custom',
    description: 'Weekend Golf Package',
    amountDisplay: '$0.00',
    awarded: false,
  },
];

export const Default: Story = {
  args: {
    prizes: mockPrizes,
    title: 'Tournament Prizes',
    showAwarded: true,
  },
};

export const BeforeAwarding: Story = {
  args: {
    prizes: mockPrizes.map(p => ({ ...p, awarded: false, awardedTo: undefined })),
    title: 'Prize Structure',
    showAwarded: true,
  },
};

export const WithoutAwardedColumn: Story = {
  args: {
    prizes: mockPrizes,
    title: 'Available Prizes',
    showAwarded: false,
  },
};

export const LargePrizePool: Story = {
  args: {
    prizes: largePrizePool,
    title: 'Championship Prize Pool',
    showAwarded: true,
  },
};

export const MixedPrizeTypes: Story = {
  args: {
    prizes: mixedPrizes,
    title: 'Mixed Prize Structure',
    showAwarded: true,
  },
};

export const PartiallyAwarded: Story = {
  args: {
    prizes: [
      {
        ...mockPrizes[0],
        awarded: true,
      },
      {
        ...mockPrizes[1],
        awarded: true,
      },
      {
        ...mockPrizes[2],
        awarded: false,
        awardedTo: undefined,
      },
      {
        ...mockPrizes[3],
        awarded: false,
        awardedTo: undefined,
      },
    ],
    title: 'Tournament in Progress',
    showAwarded: true,
  },
};

export const TrophyOnly: Story = {
  args: {
    prizes: [
      {
        id: '1',
        position: 1,
        prizeType: 'Trophy',
        description: 'Club Championship Trophy',
        amountDisplay: '$0.00',
        awarded: false,
      },
      {
        id: '2',
        position: 2,
        prizeType: 'Trophy',
        description: 'Runner-up Medal',
        amountDisplay: '$0.00',
        awarded: false,
      },
      {
        id: '3',
        position: 3,
        prizeType: 'Trophy',
        description: 'Third Place Medal',
        amountDisplay: '$0.00',
        awarded: false,
      },
    ],
    title: 'Trophy Competition',
    showAwarded: false,
  },
};

export const Empty: Story = {
  args: {
    prizes: [],
    title: 'Tournament Prizes',
    showAwarded: true,
  },
};