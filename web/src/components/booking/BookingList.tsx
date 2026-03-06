import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';

interface Booking {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalFormatted: string;
  teeTime: {
    startsAt: string;
    course: { name: string };
  };
  user: { fullName: string };
}

interface BookingListProps {
  bookings: Booking[];
  onViewBooking?: (id: string) => void;
  onCancelBooking?: (id: string) => void;
}

const STATUS_VARIANTS: Record<string, 'success' | 'warning' | 'error' | 'default'> = {
  CONFIRMED: 'success',
  CHECKED_IN: 'warning',
  COMPLETED: 'default',
  CANCELLED: 'error',
  NO_SHOW: 'error',
};

export function BookingList({ bookings, onViewBooking, onCancelBooking }: BookingListProps) {
  if (bookings.length === 0) {
    return (
      <div className="rounded-lg bg-white p-8 text-center shadow-sm">
        <p className="text-gray-500">No bookings found.</p>
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-lg bg-white shadow-sm">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Confirmation</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Course</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Date/Time</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Golfer</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Players</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Status</th>
            <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Total</th>
            <th className="px-4 py-3 text-right text-xs font-medium uppercase text-gray-500">Actions</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {bookings.map((booking) => (
            <tr key={booking.id} className="hover:bg-gray-50">
              <td className="whitespace-nowrap px-4 py-3 font-mono text-sm font-medium text-gray-900">
                {booking.confirmationCode}
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                {booking.teeTime.course.name}
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                {new Date(booking.teeTime.startsAt).toLocaleString()}
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                {booking.user.fullName}
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                {booking.playersCount}
              </td>
              <td className="whitespace-nowrap px-4 py-3">
                <Badge variant={STATUS_VARIANTS[booking.status] || 'default'}>
                  {booking.status.replace('_', ' ')}
                </Badge>
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-sm font-medium text-gray-900">
                {booking.totalFormatted}
              </td>
              <td className="whitespace-nowrap px-4 py-3 text-right">
                <div className="flex justify-end gap-2">
                  <Button size="sm" variant="ghost" onClick={() => onViewBooking?.(booking.id)}>
                    View
                  </Button>
                  {booking.status === 'CONFIRMED' && (
                    <Button size="sm" variant="danger" onClick={() => onCancelBooking?.(booking.id)}>
                      Cancel
                    </Button>
                  )}
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
