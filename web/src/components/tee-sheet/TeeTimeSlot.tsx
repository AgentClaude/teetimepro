import { format, parseISO } from 'date-fns';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';

export interface TeeTimeData {
  id: string;
  startsAt: string;
  maxPlayers: number;
  bookedPlayers: number;
  status: 'AVAILABLE' | 'PARTIALLY_BOOKED' | 'FULLY_BOOKED' | 'BLOCKED' | 'MAINTENANCE';
  priceCents: number | null;
  bookings?: {
    id: string;
    confirmationCode: string;
    playersCount: number;
    user: { fullName: string };
  }[];
}

interface TeeTimeSlotProps {
  teeTime: TeeTimeData;
  onBook?: () => void;
  onEdit?: () => void;
}

const STATUS_CONFIG = {
  AVAILABLE: { label: 'Open', variant: 'success' as const },
  PARTIALLY_BOOKED: { label: 'Partial', variant: 'warning' as const },
  FULLY_BOOKED: { label: 'Full', variant: 'error' as const },
  BLOCKED: { label: 'Blocked', variant: 'default' as const },
  MAINTENANCE: { label: 'Maintenance', variant: 'default' as const },
};

export function TeeTimeSlot({ teeTime, onBook, onEdit }: TeeTimeSlotProps) {
  const time = format(parseISO(teeTime.startsAt), 'h:mm a');
  const availableSpots = teeTime.maxPlayers - teeTime.bookedPlayers;
  const statusConfig = STATUS_CONFIG[teeTime.status];
  const isBookable = teeTime.status === 'AVAILABLE' || teeTime.status === 'PARTIALLY_BOOKED';
  const price = teeTime.priceCents ? `$${(teeTime.priceCents / 100).toFixed(2)}` : '—';

  return (
    <div
      className={`grid grid-cols-12 items-center gap-px px-4 py-3 transition-colors hover:bg-gray-50 ${
        teeTime.status === 'BLOCKED' || teeTime.status === 'MAINTENANCE'
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
            {teeTime.bookings.map((booking) => (
              <div key={booking.id} className="text-xs text-gray-600">
                {booking.user.fullName} ({booking.playersCount}p) · {booking.confirmationCode}
              </div>
            ))}
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
