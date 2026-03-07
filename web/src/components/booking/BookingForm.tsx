import { useState, useMemo, useCallback } from 'react';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQuery, useLazyQuery } from '@apollo/client';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { LoadingSpinner } from '../ui/LoadingSpinner';
import { StripeProvider } from '../payment/StripeProvider';
import { PaymentForm } from '../payment/PaymentForm';
import { CREATE_PAYMENT_INTENT, CREATE_BOOKING, CALCULATE_TEE_TIME_PRICE } from '../../graphql/mutations';
import { CHECK_AVAILABILITY, GET_LOYALTY_ACCOUNT, GET_LOYALTY_REWARDS } from '../../graphql/queries';
import type { AvailableSlot, AvailabilitySearchResult } from '../../types';
import type { LoyaltyAccount, LoyaltyReward } from '../../types/loyalty';

// ─── Schemas ────────────────────────────────────────────────────────────────

const playerDetailSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email').or(z.literal('')).optional(),
  phone: z.string().optional(),
});

const bookingFormSchema = z.object({
  playersCount: z.number().min(1, 'At least 1 player').max(4, 'Maximum 4 players'),
  players: z.array(playerDetailSchema),
  notes: z.string().max(500).optional(),
  loyaltyRedemptionCode: z.string().optional(),
});

type BookingFormData = z.infer<typeof bookingFormSchema>;

// ─── Types ──────────────────────────────────────────────────────────────────

export interface BookingFormProps {
  /** Pre-selected tee time slot (from AvailabilitySearch) */
  selectedSlot?: AvailableSlot | null;
  /** Course ID for availability search */
  courseId?: string;
  /** Available courses for selection */
  courses?: Array<{ id: string; name: string }>;
  /** Callback after successful booking */
  onBookingComplete?: (booking: BookingResult) => void;
  /** Cancel handler */
  onCancel?: () => void;
  /** Skip availability search and use provided tee time directly */
  teeTime?: {
    id: string;
    startsAt: string;
    availableSpots: number;
    priceCents: number;
    courseName: string;
  };
}

interface BookingResult {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalCents: number;
}

interface PricingCalculation {
  originalPriceCents: number;
  dynamicPriceCents: number;
  priceAdjustmentCents: number;
  appliedRules: Array<{
    id: string;
    name: string;
    ruleType: string;
    multiplier: number;
    flatAdjustmentCents: number;
  }>;
  priceBreakdown: Array<{
    step: string;
    description: string;
    priceCents: number;
    adjustmentCents: number;
  }>;
}

enum BookingStep {
  SELECT_TIME = 'select_time',
  DETAILS = 'details',
  REVIEW = 'review',
  PAYMENT = 'payment',
  CONFIRMATION = 'confirmation',
}

// ─── Helpers ────────────────────────────────────────────────────────────────

function formatCurrency(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatTime(isoString: string): string {
  return new Date(isoString).toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
}

function formatDate(isoString: string): string {
  return new Date(isoString + 'T00:00:00').toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  });
}

// ─── Component ──────────────────────────────────────────────────────────────

export function BookingForm({
  selectedSlot: initialSlot,
  courseId: initialCourseId,
  courses,
  onBookingComplete,
  onCancel,
  teeTime: directTeeTime,
}: BookingFormProps) {
  // State
  const [currentStep, setCurrentStep] = useState<BookingStep>(
    initialSlot || directTeeTime ? BookingStep.DETAILS : BookingStep.SELECT_TIME
  );
  const [selectedSlot, setSelectedSlot] = useState<AvailableSlot | null>(initialSlot ?? null);
  const [clientSecret, setClientSecret] = useState('');
  const [paymentError, setPaymentError] = useState('');
  const [bookingResult, setBookingResult] = useState<BookingResult | null>(null);
  const [selectedCourseId, setSelectedCourseId] = useState(initialCourseId ?? '');
  const [searchDate, setSearchDate] = useState(() => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toISOString().split('T')[0];
  });
  const [appliedReward, setAppliedReward] = useState<LoyaltyReward | null>(null);

  // Form
  const {
    register,
    handleSubmit,
    watch,
    control,
    setValue,
    getValues,
    formState: { errors },
  } = useForm<BookingFormData>({
    resolver: zodResolver(bookingFormSchema),
    defaultValues: {
      playersCount: 1,
      players: [{ name: '', email: '', phone: '' }],
      notes: '',
      loyaltyRedemptionCode: '',
    },
  });

  const { fields, append, remove } = useFieldArray({
    control,
    name: 'players',
  });

  const playersCount = watch('playersCount');

  // Sync player fields array with playersCount
  const handlePlayersCountChange = useCallback(
    (count: number) => {
      setValue('playersCount', count);
      const currentFields = getValues('players');
      if (count > currentFields.length) {
        for (let i = currentFields.length; i < count; i++) {
          append({ name: '', email: '', phone: '' });
        }
      } else if (count < currentFields.length) {
        for (let i = currentFields.length - 1; i >= count; i--) {
          remove(i);
        }
      }
    },
    [setValue, getValues, append, remove]
  );

  // ─── Queries ────────────────────────────────────────────────────────────

  const [searchAvailability, { data: availabilityData, loading: searchLoading }] =
    useLazyQuery<{ checkAvailability: AvailabilitySearchResult }>(CHECK_AVAILABILITY, {
      fetchPolicy: 'network-only',
    });

  const { data: loyaltyData } = useQuery<{ loyaltyAccount: LoyaltyAccount }>(GET_LOYALTY_ACCOUNT, {
    fetchPolicy: 'cache-first',
  });

  const { data: rewardsData } = useQuery<{ loyaltyRewards: LoyaltyReward[] }>(GET_LOYALTY_REWARDS, {
    variables: { affordableOnly: true, activeOnly: true },
    fetchPolicy: 'cache-first',
  });

  const [calculatePrice, { data: pricingData, loading: pricingLoading }] = useMutation<{
    calculateTeeTimePrice: { calculation: PricingCalculation };
  }>(CALCULATE_TEE_TIME_PRICE);

  // ─── Mutations ──────────────────────────────────────────────────────────

  const [createPaymentIntent, { loading: creatingIntent }] = useMutation(CREATE_PAYMENT_INTENT, {
    onCompleted: (data) => {
      if (data.createPaymentIntent.clientSecret) {
        setClientSecret(data.createPaymentIntent.clientSecret);
        setCurrentStep(BookingStep.PAYMENT);
      } else {
        setPaymentError('Failed to create payment intent. Please try again.');
      }
    },
    onError: (error) => setPaymentError(error.message),
  });

  const [createBooking, { loading: bookingLoading }] = useMutation(CREATE_BOOKING, {
    onCompleted: (data) => {
      if (data.createBooking.errors?.length > 0) {
        setPaymentError(data.createBooking.errors.join(', '));
      } else {
        setBookingResult(data.createBooking.booking);
        setCurrentStep(BookingStep.CONFIRMATION);
        onBookingComplete?.(data.createBooking.booking);
      }
    },
    onError: (error) => setPaymentError(error.message),
  });

  // ─── Derived ────────────────────────────────────────────────────────────

  const effectiveSlot = selectedSlot;
  const effectivePriceCents = useMemo(() => {
    if (directTeeTime) return directTeeTime.priceCents;
    if (!effectiveSlot) return 0;
    return effectiveSlot.dynamicPriceCents ?? effectiveSlot.basePriceCents ?? 0;
  }, [effectiveSlot, directTeeTime]);

  const loyaltyAccount = loyaltyData?.loyaltyAccount ?? null;
  const availableRewards = rewardsData?.loyaltyRewards ?? [];

  const loyaltyDiscountCents = useMemo(() => {
    if (!appliedReward) return 0;
    const subtotal = effectivePriceCents * playersCount;
    switch (appliedReward.rewardType) {
      case 'discount_percentage':
        return Math.round((subtotal * (appliedReward.discountValue ?? 0)) / 100);
      case 'discount_fixed':
        return Math.round((appliedReward.discountValue ?? 0) * 100);
      case 'free_round':
        return effectivePriceCents; // One player free
      default:
        return 0;
    }
  }, [appliedReward, effectivePriceCents, playersCount]);

  const subtotalCents = effectivePriceCents * (playersCount || 1);
  const totalCents = Math.max(subtotalCents - loyaltyDiscountCents, 0);

  const maxSpots = directTeeTime?.availableSpots ?? effectiveSlot?.availableSpots ?? 4;
  const courseName = directTeeTime?.courseName ?? effectiveSlot?.courseName ?? '';
  const teeTimeId = directTeeTime?.id ?? effectiveSlot?.teeTimeId ?? '';
  const startsAt = directTeeTime?.startsAt ?? effectiveSlot?.startsAt ?? '';

  // ─── Handlers ───────────────────────────────────────────────────────────

  const handleSearch = () => {
    searchAvailability({
      variables: {
        courseId: selectedCourseId || undefined,
        date: searchDate,
        players: playersCount,
        includePricing: true,
      },
    });
  };

  const handleSlotSelect = (slot: AvailableSlot) => {
    setSelectedSlot(slot);
    setCurrentStep(BookingStep.DETAILS);
    // Pre-fetch pricing
    calculatePrice({ variables: { teeTimeId: slot.teeTimeId } });
  };

  const handleDetailsSubmit = (data: BookingFormData) => {
    setPaymentError('');

    if (totalCents > 0) {
      createPaymentIntent({
        variables: {
          teeTimeId: teeTimeId,
          playersCount: data.playersCount,
        },
      });
    } else {
      // Free booking (full loyalty discount)
      submitBooking(data);
    }
  };

  const submitBooking = (data: BookingFormData, paymentMethodId?: string) => {
    createBooking({
      variables: {
        teeTimeId: teeTimeId,
        playersCount: data.playersCount,
        paymentMethodId: paymentMethodId ?? undefined,
        playerDetails: data.players.map((p) => ({
          name: p.name,
          email: p.email || undefined,
          phone: p.phone || undefined,
        })),
        loyaltyRedemptionCode: data.loyaltyRedemptionCode || undefined,
      },
    });
  };

  const handlePaymentSuccess = (paymentMethodId: string) => {
    submitBooking(getValues(), paymentMethodId);
  };

  const handleBackStep = () => {
    if (currentStep === BookingStep.PAYMENT) {
      setCurrentStep(BookingStep.DETAILS);
      setClientSecret('');
      setPaymentError('');
    } else if (currentStep === BookingStep.DETAILS && !directTeeTime) {
      setCurrentStep(BookingStep.SELECT_TIME);
      setSelectedSlot(null);
    }
  };

  // ─── Step: Select Time ──────────────────────────────────────────────────

  if (currentStep === BookingStep.SELECT_TIME) {
    const slots = availabilityData?.checkAvailability?.slots ?? [];
    const totalAvailable = availabilityData?.checkAvailability?.totalAvailable ?? 0;

    return (
      <div className="space-y-6">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Book a Tee Time</h3>
          <p className="mt-1 text-sm text-gray-500">Select your preferred date and time</p>
        </div>

        {/* Search Controls */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div>
            <label className="block text-xs font-medium text-gray-500 mb-1">Date</label>
            <input
              type="date"
              value={searchDate}
              onChange={(e) => setSearchDate(e.target.value)}
              className="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>

          {courses && courses.length > 1 && (
            <div>
              <label className="block text-xs font-medium text-gray-500 mb-1">Course</label>
              <select
                value={selectedCourseId}
                onChange={(e) => setSelectedCourseId(e.target.value)}
                className="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 focus:outline-none focus:ring-2 focus:ring-green-500"
              >
                <option value="">All Courses</option>
                {courses.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>
          )}

          <div className="flex items-end">
            <Button
              type="button"
              variant="primary"
              fullWidth
              onClick={handleSearch}
              loading={searchLoading}
            >
              Search
            </Button>
          </div>
        </div>

        {/* Results */}
        {searchLoading && (
          <div className="flex flex-col items-center py-12">
            <LoadingSpinner size="lg" />
            <p className="mt-3 text-sm text-gray-500">Searching available tee times…</p>
          </div>
        )}

        {!searchLoading && availabilityData && (
          <div>
            <p className="text-sm text-gray-600 mb-3">
              <span className="font-semibold text-gray-900">{totalAvailable}</span> tee time
              {totalAvailable !== 1 ? 's' : ''} available
              {searchDate && ` on ${formatDate(searchDate)}`}
            </p>

            {slots.length === 0 ? (
              <div className="rounded-lg border border-dashed border-gray-300 py-12 text-center">
                <p className="text-sm font-medium text-gray-900">No tee times available</p>
                <p className="mt-1 text-sm text-gray-500">
                  Try a different date or adjust your player count.
                </p>
              </div>
            ) : (
              <div className="space-y-2">
                {slots.map((slot) => (
                  <button
                    key={slot.teeTimeId}
                    onClick={() => handleSlotSelect(slot)}
                    className="w-full flex items-center justify-between rounded-lg border border-gray-200 px-4 py-3 transition-colors hover:border-green-300 hover:bg-green-50 text-left"
                  >
                    <div className="flex items-center gap-4">
                      <div className="text-center min-w-[64px]">
                        <p className="text-lg font-bold text-gray-900">{slot.formattedTime}</p>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{slot.courseName}</p>
                        <p
                          className={`text-xs font-medium ${
                            slot.availableSpots <= 1
                              ? 'text-red-600'
                              : slot.availableSpots <= 2
                                ? 'text-orange-600'
                                : 'text-green-600'
                          }`}
                        >
                          {slot.availableSpots} spot{slot.availableSpots !== 1 ? 's' : ''} left
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      {slot.hasDynamicPricing &&
                        slot.formattedBasePrice !== slot.formattedDynamicPrice && (
                          <p className="text-xs text-gray-400 line-through">
                            {slot.formattedBasePrice}
                          </p>
                        )}
                      <p className="text-lg font-bold text-gray-900">
                        {slot.formattedDynamicPrice ?? slot.formattedBasePrice ?? '—'}
                      </p>
                      <p className="text-xs text-gray-500">per player</p>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
        )}

        {onCancel && (
          <div className="pt-2">
            <Button type="button" variant="ghost" onClick={onCancel}>
              Cancel
            </Button>
          </div>
        )}
      </div>
    );
  }

  // ─── Step: Confirmation ─────────────────────────────────────────────────

  if (currentStep === BookingStep.CONFIRMATION && bookingResult) {
    return (
      <div className="space-y-6 text-center">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
          <svg className="h-8 w-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <div>
          <h3 className="text-xl font-semibold text-gray-900">Booking Confirmed!</h3>
          <p className="mt-1 text-sm text-gray-500">
            Your tee time has been booked successfully.
          </p>
        </div>
        <div className="rounded-lg bg-gray-50 p-4 text-left space-y-2">
          <div className="flex justify-between text-sm">
            <span className="text-gray-500">Confirmation Code</span>
            <span className="font-mono font-bold text-gray-900">{bookingResult.confirmationCode}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-500">Players</span>
            <span className="text-gray-900">{bookingResult.playersCount}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-500">Total</span>
            <span className="font-semibold text-gray-900">{formatCurrency(bookingResult.totalCents)}</span>
          </div>
          {courseName && (
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Course</span>
              <span className="text-gray-900">{courseName}</span>
            </div>
          )}
          {startsAt && (
            <div className="flex justify-between text-sm">
              <span className="text-gray-500">Tee Time</span>
              <span className="text-gray-900">{formatTime(startsAt)}</span>
            </div>
          )}
        </div>
        {onCancel && (
          <Button type="button" variant="primary" onClick={onCancel} fullWidth>
            Done
          </Button>
        )}
      </div>
    );
  }

  // ─── Step: Payment ──────────────────────────────────────────────────────

  if (currentStep === BookingStep.PAYMENT && clientSecret) {
    return (
      <div className="space-y-6">
        <div className="flex items-center gap-2">
          <Button type="button" variant="ghost" size="sm" onClick={handleBackStep}>
            ← Back
          </Button>
          <div>
            <h3 className="text-lg font-semibold text-gray-900">Complete Payment</h3>
            <p className="text-sm text-gray-500">
              {courseName} · {startsAt ? formatTime(startsAt) : ''}
            </p>
          </div>
        </div>

        <PricingSummary
          priceCents={effectivePriceCents}
          playersCount={playersCount}
          loyaltyDiscountCents={loyaltyDiscountCents}
          appliedReward={appliedReward}
          hasDynamicPricing={effectiveSlot?.hasDynamicPricing}
          basePriceCents={effectiveSlot?.basePriceCents ?? undefined}
        />

        {paymentError && <ErrorAlert message={paymentError} />}

        <StripeProvider clientSecret={clientSecret}>
          <PaymentForm
            clientSecret={clientSecret}
            amount={totalCents}
            onSuccess={handlePaymentSuccess}
            onError={(error) => setPaymentError(error)}
            loading={bookingLoading}
          />
        </StripeProvider>
      </div>
    );
  }

  // ─── Step: Details ──────────────────────────────────────────────────────

  return (
    <form onSubmit={handleSubmit(handleDetailsSubmit)} className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-2">
        {!directTeeTime && (
          <Button type="button" variant="ghost" size="sm" onClick={handleBackStep}>
            ← Back
          </Button>
        )}
        <div>
          <h3 className="text-lg font-semibold text-gray-900">Book Tee Time</h3>
          <p className="mt-1 text-sm text-gray-500">
            {courseName}
            {startsAt && ` · ${formatTime(startsAt)}`}
            {effectiveSlot?.date && ` · ${formatDate(effectiveSlot.date)}`}
          </p>
        </div>
      </div>

      {/* Number of Players */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Number of Players</label>
        <div className="flex gap-2">
          {Array.from({ length: Math.min(maxSpots, 4) }, (_, i) => i + 1).map((n) => (
            <button
              key={n}
              type="button"
              onClick={() => handlePlayersCountChange(n)}
              className={`flex-1 rounded-lg border-2 py-3 text-center font-medium transition-colors ${
                playersCount === n
                  ? 'border-green-500 bg-green-50 text-green-700'
                  : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300'
              }`}
            >
              {n}
            </button>
          ))}
        </div>
        {errors.playersCount && (
          <p className="mt-1 text-sm text-red-600">{errors.playersCount.message}</p>
        )}
      </div>

      {/* Player Details */}
      <div className="space-y-4">
        <label className="block text-sm font-medium text-gray-700">Player Details</label>
        {fields.map((field, index) => (
          <div key={field.id} className="rounded-lg border border-gray-200 p-4 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium text-gray-700">
                Player {index + 1}
                {index === 0 && (
                  <span className="ml-2 text-xs text-gray-400">(you)</span>
                )}
              </span>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <Input
                {...register(`players.${index}.name`)}
                label="Name"
                placeholder={index === 0 ? 'Your name' : `Player ${index + 1} name`}
                error={errors.players?.[index]?.name?.message}
              />
              <Input
                {...register(`players.${index}.email`)}
                label="Email"
                type="email"
                placeholder={index === 0 ? 'your@email.com' : 'Optional'}
                error={errors.players?.[index]?.email?.message}
              />
            </div>
          </div>
        ))}
      </div>

      {/* Notes */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Notes</label>
        <textarea
          {...register('notes')}
          rows={2}
          className="block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500"
          placeholder="Cart needed, special requests..."
        />
      </div>

      {/* Loyalty / Discounts */}
      {loyaltyAccount && loyaltyAccount.pointsBalance > 0 && (
        <LoyaltySection
          account={loyaltyAccount}
          rewards={availableRewards}
          appliedReward={appliedReward}
          onApplyReward={(reward, code) => {
            setAppliedReward(reward);
            setValue('loyaltyRedemptionCode', code);
          }}
          onRemoveReward={() => {
            setAppliedReward(null);
            setValue('loyaltyRedemptionCode', '');
          }}
        />
      )}

      {/* Pricing Summary */}
      <PricingSummary
        priceCents={effectivePriceCents}
        playersCount={playersCount}
        loyaltyDiscountCents={loyaltyDiscountCents}
        appliedReward={appliedReward}
        hasDynamicPricing={effectiveSlot?.hasDynamicPricing}
        basePriceCents={effectiveSlot?.basePriceCents ?? undefined}
        pricingCalculation={pricingData?.calculateTeeTimePrice?.calculation}
        pricingLoading={pricingLoading}
      />

      {paymentError && <ErrorAlert message={paymentError} />}

      {/* Actions */}
      <div className="flex gap-3">
        <Button
          type="submit"
          variant="primary"
          className="flex-1"
          loading={creatingIntent || bookingLoading}
        >
          {totalCents > 0
            ? `Continue to Payment · ${formatCurrency(totalCents)}`
            : 'Complete Booking (Free)'}
        </Button>
        {onCancel && (
          <Button type="button" variant="ghost" onClick={onCancel}>
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}

// ─── Sub-Components ───────────────────────────────────────────────────────

interface PricingSummaryProps {
  priceCents: number;
  playersCount: number;
  loyaltyDiscountCents: number;
  appliedReward: LoyaltyReward | null;
  hasDynamicPricing?: boolean;
  basePriceCents?: number;
  pricingCalculation?: PricingCalculation;
  pricingLoading?: boolean;
}

function PricingSummary({
  priceCents,
  playersCount,
  loyaltyDiscountCents,
  appliedReward,
  hasDynamicPricing,
  basePriceCents,
  pricingCalculation,
  pricingLoading,
}: PricingSummaryProps) {
  const subtotal = priceCents * playersCount;
  const total = Math.max(subtotal - loyaltyDiscountCents, 0);

  return (
    <div className="rounded-lg bg-gray-50 border border-gray-200 p-4 space-y-2">
      <h4 className="text-sm font-semibold text-gray-900 mb-2">Price Breakdown</h4>

      {/* Dynamic pricing note */}
      {hasDynamicPricing && basePriceCents !== undefined && basePriceCents !== priceCents && (
        <div className="flex justify-between text-sm">
          <span className="text-gray-500">
            Base price <span className="line-through">{formatCurrency(basePriceCents)}</span>
          </span>
          <span className="text-blue-600 font-medium">{formatCurrency(priceCents)}/player</span>
        </div>
      )}

      {/* Pricing breakdown from backend */}
      {pricingLoading && (
        <div className="flex items-center gap-2 text-xs text-gray-400">
          <LoadingSpinner size="sm" /> Calculating price…
        </div>
      )}

      {pricingCalculation?.appliedRules && pricingCalculation.appliedRules.length > 0 && (
        <div className="space-y-1 border-b border-gray-200 pb-2 mb-2">
          {pricingCalculation.appliedRules.map((rule) => (
            <div key={rule.id} className="flex items-center gap-2 text-xs text-gray-500">
              <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs font-medium text-blue-700">
                {rule.ruleType}
              </span>
              <span>{rule.name}</span>
            </div>
          ))}
        </div>
      )}

      <div className="flex justify-between text-sm">
        <span className="text-gray-600">
          {formatCurrency(priceCents)} × {playersCount} player{playersCount !== 1 ? 's' : ''}
        </span>
        <span className="text-gray-900">{formatCurrency(subtotal)}</span>
      </div>

      {loyaltyDiscountCents > 0 && appliedReward && (
        <div className="flex justify-between text-sm text-green-700">
          <span>
            🎁 {appliedReward.name}
          </span>
          <span>−{formatCurrency(loyaltyDiscountCents)}</span>
        </div>
      )}

      <hr className="border-gray-200" />

      <div className="flex justify-between items-center">
        <span className="text-sm font-semibold text-gray-900">Total</span>
        <span className="text-xl font-bold text-green-700">{formatCurrency(total)}</span>
      </div>
    </div>
  );
}

interface LoyaltySectionProps {
  account: LoyaltyAccount;
  rewards: LoyaltyReward[];
  appliedReward: LoyaltyReward | null;
  onApplyReward: (reward: LoyaltyReward, code: string) => void;
  onRemoveReward: () => void;
}

function LoyaltySection({ account, rewards, appliedReward, onApplyReward, onRemoveReward }: LoyaltySectionProps) {
  const [redeemReward] = useMutation(REDEEM_REWARD_MUTATION);
  const [redeeming, setRedeeming] = useState(false);

  const handleRedeem = async (reward: LoyaltyReward) => {
    setRedeeming(true);
    try {
      const { data } = await redeemReward({ variables: { rewardId: reward.id } });
      if (data?.redeemReward?.redemption) {
        onApplyReward(reward, data.redeemReward.redemption.code);
      }
    } finally {
      setRedeeming(false);
    }
  };

  return (
    <div className="rounded-lg border border-amber-200 bg-amber-50 p-4 space-y-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-lg">⭐</span>
          <div>
            <h4 className="text-sm font-semibold text-amber-900">Loyalty Points</h4>
            <p className="text-xs text-amber-700">
              {account.pointsBalance.toLocaleString()} pts ({account.tierName})
            </p>
          </div>
        </div>
      </div>

      {appliedReward ? (
        <div className="flex items-center justify-between rounded-md bg-green-50 border border-green-200 px-3 py-2">
          <div className="flex items-center gap-2 text-sm text-green-800">
            <span>🎁</span>
            <span className="font-medium">{appliedReward.name}</span>
            <span className="text-green-600">{appliedReward.discountDisplay}</span>
          </div>
          <button
            type="button"
            onClick={onRemoveReward}
            className="text-xs text-red-600 hover:text-red-800 font-medium"
          >
            Remove
          </button>
        </div>
      ) : (
        rewards.length > 0 && (
          <div className="space-y-2">
            <p className="text-xs text-amber-700">Available rewards:</p>
            {rewards.slice(0, 3).map((reward) => (
              <button
                key={reward.id}
                type="button"
                disabled={redeeming || !reward.canBeRedeemed}
                onClick={() => handleRedeem(reward)}
                className="w-full flex items-center justify-between rounded-md border border-amber-200 bg-white px-3 py-2 text-sm transition-colors hover:bg-amber-50 disabled:opacity-50"
              >
                <div className="text-left">
                  <span className="font-medium text-gray-900">{reward.name}</span>
                  <span className="ml-2 text-xs text-gray-500">{reward.discountDisplay}</span>
                </div>
                <span className="text-xs font-medium text-amber-700">
                  {reward.pointsCost.toLocaleString()} pts
                </span>
              </button>
            ))}
          </div>
        )
      )}
    </div>
  );
}

function ErrorAlert({ message }: { message: string }) {
  return (
    <div className="rounded-lg bg-red-50 border border-red-200 p-4">
      <div className="flex items-center gap-2">
        <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
          <path
            fillRule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
            clipRule="evenodd"
          />
        </svg>
        <p className="text-sm text-red-800">{message}</p>
      </div>
    </div>
  );
}

// We need REDEEM_REWARD imported from mutations - define inline to avoid circular deps
import { gql } from '@apollo/client';

const REDEEM_REWARD_MUTATION = gql`
  mutation RedeemRewardForBooking($rewardId: ID!) {
    redeemReward(rewardId: $rewardId) {
      redemption {
        id
        status
        code
        expiresAt
        loyaltyReward {
          id
          name
          discountDisplay
        }
      }
      account {
        id
        pointsBalance
        lifetimePoints
        tier
        tierName
      }
      errors
    }
  }
`;
