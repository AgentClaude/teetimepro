import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';

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

export function BookingForm({ teeTime, onSubmit, onCancel, loading }: BookingFormProps) {
  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<BookingFormData>({
    resolver: zodResolver(bookingSchema),
    defaultValues: {
      playersCount: 1,
      playerNames: [],
      notes: '',
    },
  });

  const playersCount = watch('playersCount');
  const totalPrice = (teeTime.priceCents * (playersCount || 1)) / 100;

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
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

      {/* Actions */}
      <div className="flex gap-3">
        <Button type="submit" variant="primary" className="flex-1" disabled={loading}>
          {loading ? 'Booking...' : `Confirm Booking · $${totalPrice.toFixed(2)}`}
        </Button>
        <Button type="button" variant="ghost" onClick={onCancel}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
