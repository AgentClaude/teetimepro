import type { Meta, StoryObj } from '@storybook/react';
import { MockedProvider, type MockedResponse } from '@apollo/client/testing';
import { BookingForm } from './BookingForm';
import { CHECK_AVAILABILITY, GET_LOYALTY_ACCOUNT, GET_LOYALTY_REWARDS } from '../../graphql/queries';
import { CALCULATE_TEE_TIME_PRICE } from '../../graphql/mutations';
import type { AvailableSlot } from '../../types';

// ─── Mock Data ──────────────────────────────────────────────────────────────

function mockSlot(overrides: Partial<AvailableSlot> = {}): AvailableSlot {
  return {
    teeTimeId: `tt-${Math.random().toString(36).slice(2, 8)}`,
    courseId: '1',
    courseName: 'Pine Valley Golf Club',
    date: '2026-03-08',
    startsAt: '2026-03-08T09:00:00Z',
    formattedTime: '9:00 AM',
    availableSpots: 4,
    maxPlayers: 4,
    bookedPlayers: 0,
    basePriceCents: 5000,
    dynamicPriceCents: 5000,
    pricePerPlayerCents: 5000,
    totalPriceCents: 10000,
    hasDynamicPricing: false,
    appliedRules: [],
    formattedBasePrice: '$50.00',
    formattedDynamicPrice: '$50.00',
    formattedTotalPrice: '$100.00',
    ...overrides,
  };
}

const standardSlot = mockSlot({
  teeTimeId: 'tt-1',
  formattedTime: '9:00 AM',
});

const dynamicPricingSlot = mockSlot({
  teeTimeId: 'tt-2',
  formattedTime: '8:00 AM',
  basePriceCents: 5000,
  dynamicPriceCents: 6500,
  pricePerPlayerCents: 6500,
  totalPriceCents: 13000,
  hasDynamicPricing: true,
  appliedRules: ['Peak morning pricing'],
  formattedBasePrice: '$50.00',
  formattedDynamicPrice: '$65.00',
  formattedTotalPrice: '$130.00',
  availableSpots: 2,
  bookedPlayers: 2,
});

const twilightSlot = mockSlot({
  teeTimeId: 'tt-3',
  formattedTime: '4:30 PM',
  startsAt: '2026-03-08T16:30:00Z',
  basePriceCents: 5000,
  dynamicPriceCents: 3500,
  pricePerPlayerCents: 3500,
  totalPriceCents: 7000,
  hasDynamicPricing: true,
  appliedRules: ['Twilight discount'],
  formattedBasePrice: '$50.00',
  formattedDynamicPrice: '$35.00',
  formattedTotalPrice: '$70.00',
});

const limitedAvailabilitySlot = mockSlot({
  teeTimeId: 'tt-4',
  formattedTime: '10:30 AM',
  availableSpots: 1,
  bookedPlayers: 3,
});

// ─── Mocks ──────────────────────────────────────────────────────────────────

const loyaltyAccountMock: MockedResponse = {
  request: { query: GET_LOYALTY_ACCOUNT },
  result: {
    data: {
      loyaltyAccount: {
        id: 'la-1',
        pointsBalance: 2500,
        lifetimePoints: 8000,
        tier: 'gold',
        tierName: 'Gold',
        pointsNeededForNextTier: 2000,
        createdAt: '2025-01-01T00:00:00Z',
        updatedAt: '2026-03-01T00:00:00Z',
        loyaltyProgram: {
          id: 'lp-1',
          name: 'Golf Rewards',
          description: 'Earn points on every booking',
          pointsPerDollar: 10,
        },
        recentTransactions: [],
      },
    },
  },
};

const noLoyaltyMock: MockedResponse = {
  request: { query: GET_LOYALTY_ACCOUNT },
  result: { data: { loyaltyAccount: null } },
};

const loyaltyRewardsMock: MockedResponse = {
  request: {
    query: GET_LOYALTY_REWARDS,
    variables: { affordableOnly: true, activeOnly: true },
  },
  result: {
    data: {
      loyaltyRewards: [
        {
          id: 'lr-1',
          name: '$10 Off Booking',
          description: 'Save $10 on your next tee time',
          pointsCost: 1000,
          rewardType: 'discount_fixed',
          discountValue: 10,
          discountDisplay: '$10.00 off',
          isActive: true,
          maxRedemptionsPerUser: null,
          canBeRedeemed: true,
          remainingRedemptions: null,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        },
        {
          id: 'lr-2',
          name: '20% Off',
          description: '20% discount on your booking',
          pointsCost: 2000,
          rewardType: 'discount_percentage',
          discountValue: 20,
          discountDisplay: '20% off',
          isActive: true,
          maxRedemptionsPerUser: null,
          canBeRedeemed: true,
          remainingRedemptions: null,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        },
        {
          id: 'lr-3',
          name: 'Free Round',
          description: 'One free round of golf',
          pointsCost: 5000,
          rewardType: 'free_round',
          discountValue: null,
          discountDisplay: 'Free round',
          isActive: true,
          maxRedemptionsPerUser: 1,
          canBeRedeemed: false,
          remainingRedemptions: 0,
          createdAt: '2025-01-01T00:00:00Z',
          updatedAt: '2025-01-01T00:00:00Z',
        },
      ],
    },
  },
};

const noRewardsMock: MockedResponse = {
  request: {
    query: GET_LOYALTY_REWARDS,
    variables: { affordableOnly: true, activeOnly: true },
  },
  result: { data: { loyaltyRewards: [] } },
};

const pricingMock = (teeTimeId: string): MockedResponse => ({
  request: {
    query: CALCULATE_TEE_TIME_PRICE,
    variables: { teeTimeId },
  },
  result: {
    data: {
      calculateTeeTimePrice: {
        calculation: {
          originalPriceCents: 5000,
          originalPrice: '$50.00',
          dynamicPriceCents: 5000,
          dynamicPrice: '$50.00',
          priceAdjustmentCents: 0,
          priceAdjustment: '$0.00',
          appliedRules: [],
          priceBreakdown: [
            { step: 'base_price', description: 'Base tee time price', priceCents: 5000, price: '$50.00', adjustmentCents: 0, adjustment: '$0.00', ruleType: null, multiplier: 1.0, flatAdjustmentCents: 0, flatAdjustment: '$0.00' },
          ],
        },
      },
    },
  },
});

const availabilityMock: MockedResponse = {
  request: {
    query: CHECK_AVAILABILITY,
    variables: {
      date: '2026-03-08',
      players: 1,
      includePricing: true,
    },
  },
  result: {
    data: {
      checkAvailability: {
        slots: [
          mockSlot({ teeTimeId: 'tt-a', formattedTime: '7:00 AM' }),
          mockSlot({ teeTimeId: 'tt-b', formattedTime: '7:10 AM', availableSpots: 3, bookedPlayers: 1 }),
          mockSlot({
            teeTimeId: 'tt-c',
            formattedTime: '8:00 AM',
            hasDynamicPricing: true,
            basePriceCents: 5000,
            dynamicPriceCents: 6500,
            formattedBasePrice: '$50.00',
            formattedDynamicPrice: '$65.00',
            availableSpots: 1,
            bookedPlayers: 3,
          }),
          mockSlot({ teeTimeId: 'tt-d', formattedTime: '9:00 AM' }),
          mockSlot({ teeTimeId: 'tt-e', formattedTime: '10:00 AM' }),
        ],
        totalAvailable: 5,
        dateRange: { startDate: '2026-03-08', endDate: '2026-03-08', days: 1 },
        filters: { players: 1, timePreference: null, courseId: null },
      },
    },
  },
};

// ─── Stories ─────────────────────────────────────────────────────────────────

const meta: Meta<typeof BookingForm> = {
  title: 'Booking/BookingForm',
  component: BookingForm,
  parameters: {
    layout: 'centered',
  },
  decorators: [
    (Story, context) => {
      const mocks = (context.args as Record<string, unknown>)._mocks as MockedResponse[] | undefined;
      return (
        <MockedProvider mocks={mocks ?? [noLoyaltyMock, noRewardsMock]} addTypename={false}>
          <div className="w-[480px] max-w-full p-4">
            <Story />
          </div>
        </MockedProvider>
      );
    },
  ],
};

export default meta;
type Story = StoryObj<typeof BookingForm>;

/** Direct tee time booking — simplest form, skipping availability search */
export const DirectTeeTime: Story = {
  args: {
    teeTime: {
      id: 'tt-1',
      startsAt: '2026-03-08T09:00:00Z',
      availableSpots: 4,
      priceCents: 5000,
      courseName: 'Pine Valley Golf Club',
    },
    onCancel: () => alert('Cancelled'),
    onBookingComplete: (booking: Record<string, unknown>) => alert(`Booked: ${JSON.stringify(booking)}`),
    _mocks: [noLoyaltyMock, noRewardsMock],
  } as Record<string, unknown>,
};

/** Pre-selected slot from availability search */
export const WithSelectedSlot: Story = {
  args: {
    selectedSlot: standardSlot,
    onCancel: () => alert('Cancelled'),
    _mocks: [noLoyaltyMock, noRewardsMock, pricingMock('tt-1')],
  } as Record<string, unknown>,
};

/** Dynamic pricing slot showing base price strikethrough */
export const DynamicPricing: Story = {
  args: {
    selectedSlot: dynamicPricingSlot,
    onCancel: () => alert('Cancelled'),
    _mocks: [
      noLoyaltyMock,
      noRewardsMock,
      {
        request: {
          query: CALCULATE_TEE_TIME_PRICE,
          variables: { teeTimeId: 'tt-2' },
        },
        result: {
          data: {
            calculateTeeTimePrice: {
              calculation: {
                originalPriceCents: 5000,
                originalPrice: '$50.00',
                dynamicPriceCents: 6500,
                dynamicPrice: '$65.00',
                priceAdjustmentCents: 1500,
                priceAdjustment: '$15.00',
                appliedRules: [
                  {
                    id: 'pr-1',
                    name: 'Peak Morning',
                    ruleType: 'peak_pricing',
                    multiplier: 1.3,
                    flatAdjustmentCents: 0,
                    flatAdjustment: '$0.00',
                    priority: 1,
                    conditions: {},
                  },
                ],
                priceBreakdown: [
                  { step: 'base_price', description: 'Base tee time price', priceCents: 5000, price: '$50.00', adjustmentCents: 0, adjustment: '$0.00', ruleType: null, multiplier: 1.0, flatAdjustmentCents: 0, flatAdjustment: '$0.00' },
                  { step: 'rule_pr-1', description: 'Peak Morning', priceCents: 6500, price: '$65.00', adjustmentCents: 1500, adjustment: '$15.00', ruleType: 'peak_pricing', multiplier: 1.3, flatAdjustmentCents: 0, flatAdjustment: '$0.00' },
                ],
              },
            },
          },
        },
      },
    ],
  } as Record<string, unknown>,
};

/** Twilight discount pricing */
export const TwilightDiscount: Story = {
  args: {
    selectedSlot: twilightSlot,
    onCancel: () => alert('Cancelled'),
    _mocks: [noLoyaltyMock, noRewardsMock, pricingMock('tt-3')],
  } as Record<string, unknown>,
};

/** Limited availability — only 1 spot left */
export const LimitedAvailability: Story = {
  args: {
    selectedSlot: limitedAvailabilitySlot,
    onCancel: () => alert('Cancelled'),
    _mocks: [noLoyaltyMock, noRewardsMock, pricingMock('tt-4')],
  } as Record<string, unknown>,
};

/** With loyalty account and redeemable rewards */
export const WithLoyaltyRewards: Story = {
  args: {
    selectedSlot: standardSlot,
    onCancel: () => alert('Cancelled'),
    _mocks: [loyaltyAccountMock, loyaltyRewardsMock, pricingMock('tt-1')],
  } as Record<string, unknown>,
};

/** Availability search flow — starts with time selection */
export const AvailabilitySearchFlow: Story = {
  args: {
    courses: [
      { id: '1', name: 'Pine Valley Golf Club' },
      { id: '2', name: 'Sunset Ridge Course' },
    ],
    onCancel: () => alert('Cancelled'),
    _mocks: [noLoyaltyMock, noRewardsMock, availabilityMock],
  } as Record<string, unknown>,
};
