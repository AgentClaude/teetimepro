import { BookingList } from '../components/booking/BookingList';

export function BookingsPage() {
  // TODO: Wire to GraphQL query
  const bookings: [] = [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
      </div>

      <BookingList
        bookings={bookings}
        onViewBooking={(id) => console.log('View:', id)}
        onCancelBooking={(id) => console.log('Cancel:', id)}
      />
    </div>
  );
}
