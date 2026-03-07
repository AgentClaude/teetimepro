import { Link } from 'react-router-dom';
import { Badge, statusBadgeVariant } from '../ui/Badge';

interface Booking {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalCents: number;
  createdAt: string;
  teeTime?: {
    id: string;
    startsAt: string;
    formattedTime?: string;
    teeSheet?: {
      date: string;
      course?: {
        id: string;
        name: string;
      };
    };
  };
}

interface CustomerBookingsSectionProps {
  bookings: Booking[];
  emptyMessage?: string;
}

export function CustomerBookingsSection({ bookings, emptyMessage = 'No bookings' }: CustomerBookingsSectionProps) {
  if (bookings.length === 0) {
    return <p className="py-4 text-sm text-rough-500 text-center">{emptyMessage}</p>;
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-rough-200">
        <thead>
          <tr>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Confirmation</th>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Date & Time</th>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Course</th>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Players</th>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Total</th>
            <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Status</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-rough-100">
          {bookings.map((booking) => (
            <tr key={booking.id} className="hover:bg-rough-50 transition-colors">
              <td className="whitespace-nowrap px-3 py-3">
                <Link
                  to={`/bookings/${booking.id}`}
                  className="font-mono text-sm font-medium text-fairway-600 hover:text-fairway-800"
                >
                  {booking.confirmationCode}
                </Link>
              </td>
              <td className="whitespace-nowrap px-3 py-3 text-sm text-rough-700">
                {booking.teeTime?.teeSheet?.date
                  ? new Date(booking.teeTime.teeSheet.date + 'T00:00:00').toLocaleDateString(undefined, {
                      weekday: 'short',
                      month: 'short',
                      day: 'numeric',
                    })
                  : '—'}
                {booking.teeTime?.formattedTime && (
                  <span className="text-rough-500 ml-1">
                    at {booking.teeTime.formattedTime}
                  </span>
                )}
              </td>
              <td className="whitespace-nowrap px-3 py-3 text-sm text-rough-700">
                {booking.teeTime?.teeSheet?.course?.name || '—'}
              </td>
              <td className="whitespace-nowrap px-3 py-3 text-sm text-rough-700">
                {booking.playersCount}
              </td>
              <td className="whitespace-nowrap px-3 py-3 text-sm text-rough-700">
                {booking.totalCents != null ? `$${(booking.totalCents / 100).toFixed(2)}` : '—'}
              </td>
              <td className="whitespace-nowrap px-3 py-3">
                <Badge variant={statusBadgeVariant(booking.status)} size="sm">
                  {booking.status.replace('_', ' ')}
                </Badge>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
