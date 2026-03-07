import { format, parseISO } from 'date-fns';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';

export type TeeTimeStatus =
  | 'AVAILABLE' | 'available'
  | 'PARTIALLY_BOOKED' | 'partially_booked'
  | 'FULLY_BOOKED' | 'fully_booked'
  | 'BLOCKED' | 'blocked'
  | 'MAINTENANCE' | 'maintenance';

export interface TeeTimeBooking {
  id: string;
  confirmationCode: string;
  playersCount: number;
  status: string;
  hasTurnOrder: boolean;
  user: { fullName: string };
  bookingPlayers: { name: string }[];
}

export interface TeeTimeData {
  id: string;
  startsAt: string;
  maxPlayers: number;
  bookedPlayers: number;
  status: TeeTimeStatus;
  priceCents: number | null;
  bookings?: TeeTimeBooking[];
}

interface TeeTimeSlotProps {
  teeTime: TeeTimeData;
  onBook?: () => void;
  onEdit?: () => void;
  onOrderFood?: (bookingId: string, golferName: string) => void;
}

const STATUS_CONFIG: Record<string, { label: string; variant: 'success' | 'warning' | 'danger' | 'default' }> = {
  AVAILABLE: { label: 'Open', variant: 'success' },
  available: { label: 'Open', variant: 'success' },
  PARTIALLY_BOOKED: { label: 'Partial', variant: 'warning' },
  partially_booked: { label: 'Partial', variant: 'warning' },
  FULLY_BOOKED: { label: 'Full', variant: 'danger' },
  fully_booked: { label: 'Full', variant: 'danger' },
  BLOCKED: { label: 'Blocked', variant: 'default' },
  blocked: { label: 'Blocked', variant: 'default' },
  MAINTENANCE: { label: 'Maintenance', variant: 'default' },
  maintenance: { label: 'Maintenance', variant: 'default' },
};

export function TeeTimeSlot({ teeTime, onBook, onEdit, onOrderFood }: TeeTimeSlotProps) {
  const time = format(parseISO(teeTime.startsAt), 'h:mm a');
  const availableSpots = teeTime.maxPlayers - teeTime.bookedPlayers;
  const statusConfig = STATUS_CONFIG[teeTime.status] ?? { label: teeTime.status, variant: 'default' as const };
  const upperStatus = teeTime.status.toUpperCase();
  const isBookable = upperStatus === 'AVAILABLE' || upperStatus === 'PARTIALLY_BOOKED';
  const price = teeTime.priceCents ? `$${(teeTime.priceCents / 100).toFixed(2)}` : '—';

  return (
    <div
      className={`grid grid-cols-12 items-center gap-px px-4 py-3 transition-colors hover:bg-gray-50 ${
        upperStatus === 'BLOCKED' || upperStatus === 'MAINTENANCE'
          ? 'bg-gray-50 opacity-60'
          : ''
      }`}
    >
      {/* Time */}
      <div className="col-span-2">
        <span className="text-sm font-semibold text-gray-900">{time}</span>
      </div>

      {/* Players */}
      <div className="col-span-3">
        <div className="flex items-center gap-2">
          <div className="flex gap-1">
            {Array.from({ length: teeTime.maxPlayers }).map((_, i) => (
              <div
                key={i}
                className={`h-6 w-6 rounded-full border-2 ${
                  i < teeTime.bookedPlayers
                    ? 'border-green-500 bg-green-100'
                    : 'border-gray-300 bg-white'
                }`}
              />
            ))}
          </div>
          <span className="text-xs text-gray-500">
            {availableSpots}/{teeTime.maxPlayers} open
          </span>
        </div>
        {/* Booked player names */}
        {teeTime.bookings && teeTime.bookings.length > 0 && (
          <div className="mt-1 space-y-0.5">
            {teeTime.bookings.map((booking) => {
              const golferName = booking.bookingPlayers?.[0]?.name ?? booking.user.fullName;
              const canOrderFood = booking.status === 'confirmed' || booking.status === 'checked_in';
              return (
                <div key={booking.id} className="flex items-center gap-2 text-xs text-gray-600">
                  <span>
                    {booking.user.fullName} ({booking.playersCount}p) · {booking.confirmationCode}
                  </span>
                  {booking.hasTurnOrder && (
                    <span className="inline-flex items-center rounded-full bg-orange-100 px-1.5 py-0.5 text-[10px] font-medium text-orange-700">
                      🍔 ordered
                    </span>
                  )}
                  {canOrderFood && !booking.hasTurnOrder && onOrderFood && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        onOrderFood(booking.id, golferName);
                      }}
                      className="inline-flex items-center rounded bg-orange-50 px-1.5 py-0.5 text-[10px] font-medium text-orange-600 hover:bg-orange-100"
                    >
                      🍔 Order food
                    </button>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Status */}
      <div className="col-span-2">
        <Badge variant={statusConfig.variant}>{statusConfig.label}</Badge>
      </div>

      {/* Rate */}
      <div className="col-span-2">
        <span className="text-sm text-gray-700">{price}</span>
      </div>

      {/* Actions */}
      <div className="col-span-3 flex justify-end gap-2">
        {isBookable && (
          <Button size="sm" variant="primary" onClick={onBook}>
            Book
          </Button>
        )}
        <Button size="sm" variant="ghost" onClick={onEdit}>
          Edit
        </Button>
      </div>
    </div>
  );
}
