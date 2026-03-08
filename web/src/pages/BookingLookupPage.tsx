import { useState, useCallback } from 'react';
import { useLazyQuery } from '@apollo/client';
import { LOOKUP_PUBLIC_BOOKING } from '../graphql/public';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { Card } from '../components/ui/Card';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';

interface BookingResult {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalCents: number;
  bookingType: string;
  cancelledAt: string | null;
  cancellationReason: string | null;
  createdAt: string;
  courseName: string;
  teeTimeStartsAt: string;
  teeTimeFormatted: string;
  teeTimeDate: string;
  playerNames: string[];
}

const STATUS_LABELS: Record<string, { label: string; color: string }> = {
  confirmed: { label: 'Confirmed', color: 'bg-green-100 text-green-800' },
  checked_in: { label: 'Checked In', color: 'bg-blue-100 text-blue-800' },
  completed: { label: 'Completed', color: 'bg-gray-100 text-gray-800' },
  cancelled: { label: 'Cancelled', color: 'bg-red-100 text-red-800' },
  no_show: { label: 'No Show', color: 'bg-yellow-100 text-yellow-800' },
  pending_voice_confirmation: { label: 'Pending', color: 'bg-orange-100 text-orange-800' },
};

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

function formatCurrency(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

export function BookingLookupPage() {
  const [confirmationCode, setConfirmationCode] = useState('');
  const [email, setEmail] = useState('');
  const [hasSearched, setHasSearched] = useState(false);

  const [lookupBooking, { data, loading, error }] = useLazyQuery(LOOKUP_PUBLIC_BOOKING, {
    fetchPolicy: 'network-only',
  });

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      if (!confirmationCode.trim() || !email.trim()) return;

      setHasSearched(true);
      lookupBooking({
        variables: {
          confirmationCode: confirmationCode.trim(),
          email: email.trim(),
        },
      });
    },
    [confirmationCode, email, lookupBooking]
  );

  const booking: BookingResult | null = data?.publicBookingLookup ?? null;
  const statusInfo = booking ? STATUS_LABELS[booking.status] ?? { label: booking.status, color: 'bg-gray-100 text-gray-800' } : null;

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col items-center px-4 py-12">
      <div className="w-full max-w-md space-y-6">
        {/* Header */}
        <div className="text-center">
          <h1 className="text-3xl font-bold text-gray-900">Look Up Your Booking</h1>
          <p className="mt-2 text-gray-600">
            Enter your confirmation code and email to view your booking details.
          </p>
        </div>

        {/* Lookup Form */}
        <Card>
          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              label="Confirmation Code"
              type="text"
              placeholder="e.g. ABC12345"
              value={confirmationCode}
              onChange={(e) => setConfirmationCode(e.target.value.toUpperCase())}
              required
            />

            <Input
              label="Email Address"
              type="email"
              placeholder="your@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />

            <Button
              type="submit"
              disabled={loading || !confirmationCode.trim() || !email.trim()}
              className="w-full"
            >
              {loading ? 'Looking up...' : 'Find My Booking'}
            </Button>
          </form>
        </Card>

        {/* Loading */}
        {loading && (
          <div className="flex justify-center py-4">
            <LoadingSpinner />
          </div>
        )}

        {/* Error */}
        {error && (
          <Card>
            <div className="text-center py-4">
              <p className="text-red-600">Something went wrong. Please try again.</p>
            </div>
          </Card>
        )}

        {/* Not Found */}
        {hasSearched && !loading && !error && !booking && (
          <Card>
            <div className="text-center py-6">
              <svg
                className="mx-auto h-12 w-12 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1.5}
                  d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <h3 className="mt-2 text-lg font-medium text-gray-900">Booking Not Found</h3>
              <p className="mt-1 text-sm text-gray-500">
                We couldn&apos;t find a booking matching that confirmation code and email.
                Please double-check your details and try again.
              </p>
            </div>
          </Card>
        )}

        {/* Booking Details */}
        {booking && statusInfo && (
          <Card>
            <div className="space-y-6">
              {/* Status & Confirmation Code */}
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-500">Confirmation Code</p>
                  <p className="text-2xl font-mono font-bold text-gray-900 tracking-wider">
                    {booking.confirmationCode}
                  </p>
                </div>
                <span
                  className={`inline-flex items-center rounded-full px-3 py-1 text-sm font-medium ${statusInfo.color}`}
                >
                  {statusInfo.label}
                </span>
              </div>

              <hr className="border-gray-200" />

              {/* Course & Time */}
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-500">Course</p>
                  <p className="text-lg font-semibold text-gray-900">{booking.courseName}</p>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">Date</p>
                    <p className="font-medium text-gray-900">{formatDate(booking.teeTimeDate)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Tee Time</p>
                    <p className="font-medium text-gray-900">{booking.teeTimeFormatted}</p>
                  </div>
                </div>
              </div>

              <hr className="border-gray-200" />

              {/* Players */}
              <div>
                <p className="text-sm text-gray-500 mb-2">
                  Players ({booking.playersCount})
                </p>
                <ul className="space-y-1">
                  {booking.playerNames.map((name, idx) => (
                    <li key={idx} className="flex items-center text-gray-900">
                      <svg
                        className="mr-2 h-4 w-4 text-gray-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth={2}
                          d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                        />
                      </svg>
                      {name}
                    </li>
                  ))}
                </ul>
              </div>

              <hr className="border-gray-200" />

              {/* Total */}
              <div className="flex items-center justify-between">
                <p className="text-sm text-gray-500">Total</p>
                <p className="text-xl font-bold text-gray-900">
                  {formatCurrency(booking.totalCents)}
                </p>
              </div>

              {/* Cancellation Info */}
              {booking.status === 'cancelled' && (
                <div className="rounded-lg bg-red-50 p-4">
                  <p className="text-sm font-medium text-red-800">Booking Cancelled</p>
                  {booking.cancelledAt && (
                    <p className="text-sm text-red-600 mt-1">
                      Cancelled on {new Date(booking.cancelledAt).toLocaleDateString()}
                    </p>
                  )}
                  {booking.cancellationReason && (
                    <p className="text-sm text-red-600 mt-1">
                      Reason: {booking.cancellationReason}
                    </p>
                  )}
                </div>
              )}
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
