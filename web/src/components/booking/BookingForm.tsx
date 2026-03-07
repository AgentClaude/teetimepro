import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from '@apollo/client';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { StripeProvider } from '../payment/StripeProvider';
import { PaymentForm } from '../payment/PaymentForm';
import { CREATE_PAYMENT_INTENT } from '../../graphql/mutations';

const bookingSchema = z.object({
  playersCount: z.number().min(1).max(5),
  playerNames: z.array(z.string()).optional(),
  paymentMethodId: z.string().optional(),
  notes: z.string().max(500).optional(),
});

type BookingFormData = z.infer<typeof bookingSchema>;

interface BookingFormProps {
  teeTime: {
    id: string;
    startsAt: string;
    availableSpots: number;
    priceCents: number;
    courseName: string;
  };
  onSubmit: (data: BookingFormData) => void;
  onCancel: () => void;
  loading?: boolean;
}

enum BookingStep {
  DETAILS = 'details',
  PAYMENT = 'payment',
}

export function BookingForm({ teeTime, onSubmit, onCancel, loading }: BookingFormProps) {
  const [currentStep, setCurrentStep] = useState<BookingStep>(BookingStep.DETAILS);
  const [clientSecret, setClientSecret] = useState<string>('');
  const [paymentError, setPaymentError] = useState<string>('');

  const {
    register,
    handleSubmit,
    watch,
    getValues,
    formState: { errors },
  } = useForm<BookingFormData>({
    resolver: zodResolver(bookingSchema),
    defaultValues: {
      playersCount: 1,
      playerNames: [],
      notes: '',
    },
  });

  const [createPaymentIntent, { loading: creatingIntent }] = useMutation(CREATE_PAYMENT_INTENT, {
    onCompleted: (data) => {
      if (data.createPaymentIntent.clientSecret) {
        setClientSecret(data.createPaymentIntent.clientSecret);
        setCurrentStep(BookingStep.PAYMENT);
      } else {
        setPaymentError('Failed to create payment intent. Please try again.');
      }
    },
    onError: (error) => {
      setPaymentError(error.message);
    },
  });

  const playersCount = watch('playersCount');
  const totalPriceCents = teeTime.priceCents * (playersCount || 1);
  const totalPrice = totalPriceCents / 100;

  const handleDetailsSubmit = (data: BookingFormData) => {
    setPaymentError('');
    createPaymentIntent({
      variables: {
        teeTimeId: teeTime.id,
        playersCount: data.playersCount,
      },
    });
  };

  const handlePaymentSuccess = (paymentMethodId: string) => {
    const formData = getValues();
    onSubmit({
      ...formData,
      paymentMethodId,
    });
  };

  const handlePaymentError = (error: string) => {
    setPaymentError(error);
  };

  const handleBackToDetails = () => {
    setCurrentStep(BookingStep.DETAILS);
    setClientSecret('');
    setPaymentError('');
  };

  if (currentStep === BookingStep.PAYMENT && clientSecret) {
    return (
      <div className="space-y-6">
        <div>
          <div className="flex items-center gap-2 mb-4">
            <Button
              type="button"
              variant="ghost"
              onClick={handleBackToDetails}
              className="p-2"
            >
              ← Back
            </Button>
            <div>
              <h3 className="text-lg font-semibold text-gray-900">Complete Payment</h3>
              <p className="text-sm text-gray-500">
                {teeTime.courseName} · {new Date(teeTime.startsAt).toLocaleString()}
              </p>
            </div>
          </div>
        </div>

        {/* Booking Summary */}
        <div className="rounded-lg bg-gray-50 p-4">
          <h4 className="font-medium text-gray-900 mb-2">Booking Summary</h4>
          <div className="space-y-1 text-sm text-gray-600">
            <div className="flex justify-between">
              <span>Players:</span>
              <span>{playersCount}</span>
            </div>
            <div className="flex justify-between">
              <span>Price per player:</span>
              <span>${(teeTime.priceCents / 100).toFixed(2)}</span>
            </div>
            <hr className="my-2" />
            <div className="flex justify-between font-medium text-gray-900">
              <span>Total:</span>
              <span>${totalPrice.toFixed(2)}</span>
            </div>
          </div>
        </div>

        {paymentError && (
          <div className="rounded-lg bg-red-50 border border-red-200 p-4">
            <p className="text-sm text-red-800">{paymentError}</p>
          </div>
        )}

        <StripeProvider clientSecret={clientSecret}>
          <PaymentForm
            clientSecret={clientSecret}
            amount={totalPriceCents}
            onSuccess={handlePaymentSuccess}
            onError={handlePaymentError}
            loading={loading}
          />
        </StripeProvider>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit(handleDetailsSubmit)} className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900">Book Tee Time</h3>
        <p className="mt-1 text-sm text-gray-500">
          {teeTime.courseName} · {new Date(teeTime.startsAt).toLocaleString()}
        </p>
      </div>

      {/* Number of Players */}
      <div>
        <label className="block text-sm font-medium text-gray-700">Number of Players</label>
        <select
          {...register('playersCount', { valueAsNumber: true })}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          {Array.from({ length: teeTime.availableSpots }, (_, i) => i + 1).map((n) => (
            <option key={n} value={n}>
              {n} {n === 1 ? 'player' : 'players'}
            </option>
          ))}
        </select>
        {errors.playersCount && (
          <p className="mt-1 text-sm text-red-600">{errors.playersCount.message}</p>
        )}
      </div>

      {/* Player Names */}
      {playersCount > 0 && (
        <div className="space-y-3">
          <label className="block text-sm font-medium text-gray-700">Player Names</label>
          {Array.from({ length: playersCount }, (_, i) => (
            <Input
              key={i}
              {...register(`playerNames.${i}`)}
              placeholder={i === 0 ? 'Your name' : `Player ${i + 1} (optional)`}
            />
          ))}
        </div>
      )}

      {/* Notes */}
      <div>
        <label className="block text-sm font-medium text-gray-700">Notes</label>
        <textarea
          {...register('notes')}
          rows={3}
          className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          placeholder="Cart needed, special requests..."
        />
      </div>

      {/* Price Summary */}
      <div className="rounded-lg bg-green-50 p-4">
        <div className="flex items-center justify-between">
          <span className="text-sm text-gray-600">
            ${(teeTime.priceCents / 100).toFixed(2)} × {playersCount}{' '}
            {playersCount === 1 ? 'player' : 'players'}
          </span>
          <span className="text-lg font-bold text-green-700">${totalPrice.toFixed(2)}</span>
        </div>
      </div>

      {paymentError && (
        <div className="rounded-lg bg-red-50 border border-red-200 p-4">
          <p className="text-sm text-red-800">{paymentError}</p>
        </div>
      )}

      {/* Actions */}
      <div className="flex gap-3">
        <Button type="submit" variant="primary" className="flex-1" disabled={creatingIntent}>
          {creatingIntent ? 'Setting up payment...' : 'Continue to Payment'}
        </Button>
        <Button type="button" variant="ghost" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}