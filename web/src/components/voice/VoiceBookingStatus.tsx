import { useEffect, useState } from 'react';
import { CalendarIcon, UserGroupIcon, PhoneIcon } from '@heroicons/react/24/outline';
import type { Booking } from '../../types';

interface VoiceBookingStatusProps {
  bookings: Booking[];
  onRefresh?: () => void;
  className?: string;
}

interface TimeRemaining {
  minutes: number;
  seconds: number;
}

export function VoiceBookingStatus({ bookings, onRefresh, className = '' }: VoiceBookingStatusProps) {
  const [timeRemainingMap, setTimeRemainingMap] = useState<Record<string, TimeRemaining>>({});

  const pendingBookings = bookings.filter(booking => booking.status === 'pending_voice_confirmation');
  const confirmedBookings = bookings.filter(booking => booking.status === 'confirmed');

  useEffect(() => {
    if (pendingBookings.length === 0) return;

    const updateTimeRemaining = () => {
      const newTimeMap: Record<string, TimeRemaining> = {};

      pendingBookings.forEach(booking => {
        const createdAt = new Date(booking.createdAt);
        const expireAt = new Date(createdAt.getTime() + 5 * 60 * 1000); // 5 minutes
        const now = new Date();
        const remainingMs = expireAt.getTime() - now.getTime();

        if (remainingMs > 0) {
          newTimeMap[booking.id] = {
            minutes: Math.floor(remainingMs / 60000),
            seconds: Math.floor((remainingMs % 60000) / 1000),
          };
        }
      });

      setTimeRemainingMap(newTimeMap);
    };

    updateTimeRemaining();
    const interval = setInterval(updateTimeRemaining, 1000);

    return () => clearInterval(interval);
  }, [pendingBookings]);

  const formatTeeTime = (booking: Booking): string => {
    const date = new Date(booking.teeTime.startsAt);
    return date.toLocaleString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });
  };

  const formatCurrency = (cents: number): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(cents / 100);
  };

  const getStatusBadgeColor = (status: string): string => {
    switch (status) {
      case 'pending_voice_confirmation':
        return 'bg-yellow-100 text-yellow-800';
      case 'confirmed':
        return 'bg-green-100 text-green-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const PendingBookingCard = ({ booking }: { booking: Booking }) => {
    const timeRemaining = timeRemainingMap[booking.id];
    const isExpired = !timeRemaining;

    return (
      <div className={`border border-yellow-200 rounded-lg p-4 bg-yellow-50 ${isExpired ? 'opacity-60' : ''}`}>
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <PhoneIcon className="h-5 w-5 text-yellow-600" />
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusBadgeColor(booking.status)}`}>
              {isExpired ? 'Expired' : 'Pending Confirmation'}
            </span>
          </div>
          {timeRemaining && (
            <div className="text-sm font-mono text-yellow-700">
              {timeRemaining.minutes}:{timeRemaining.seconds.toString().padStart(2, '0')}
            </div>
          )}
        </div>

        <div className="space-y-2">
          <div className="flex items-center gap-2 text-sm">
            <CalendarIcon className="h-4 w-4 text-gray-500" />
            <span>{formatTeeTime(booking)}</span>
          </div>
          <div className="flex items-center gap-2 text-sm">
            <UserGroupIcon className="h-4 w-4 text-gray-500" />
            <span>{booking.playersCount} player{booking.playersCount !== 1 ? 's' : ''}</span>
          </div>
          <div className="flex items-center gap-2 text-sm">
            <span className="text-gray-500">Total:</span>
            <span className="font-medium">{formatCurrency(booking.totalCents)}</span>
          </div>
        </div>

        <div className="mt-3 pt-3 border-t border-yellow-200">
          <div className="text-xs text-yellow-700">
            Confirmation Code: <span className="font-mono font-medium">{booking.confirmationCode}</span>
          </div>
          {isExpired && (
            <div className="text-xs text-red-600 mt-1">
              Booking expired - call was not confirmed within 5 minutes
            </div>
          )}
        </div>
      </div>
    );
  };

  const ConfirmedBookingCard = ({ booking }: { booking: Booking }) => (
    <div className="border border-green-200 rounded-lg p-4 bg-green-50">
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2">
          <PhoneIcon className="h-5 w-5 text-green-600" />
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusBadgeColor(booking.status)}`}>
            Confirmed
          </span>
        </div>
      </div>

      <div className="space-y-2">
        <div className="flex items-center gap-2 text-sm">
          <CalendarIcon className="h-4 w-4 text-gray-500" />
          <span>{formatTeeTime(booking)}</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <UserGroupIcon className="h-4 w-4 text-gray-500" />
          <span>{booking.playersCount} player{booking.playersCount !== 1 ? 's' : ''}</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <span className="text-gray-500">Total:</span>
          <span className="font-medium">{formatCurrency(booking.totalCents)}</span>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <span className="text-gray-500">Golfer:</span>
          <span>{booking.user.fullName}</span>
        </div>
      </div>

      <div className="mt-3 pt-3 border-t border-green-200">
        <div className="text-xs text-green-700">
          Confirmation Code: <span className="font-mono font-medium">{booking.confirmationCode}</span>
        </div>
      </div>
    </div>
  );

  if (bookings.length === 0) {
    return (
      <div className={`text-center py-8 ${className}`}>
        <PhoneIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
        <p className="text-gray-500">No voice bookings found</p>
      </div>
    );
  }

  return (
    <div className={`space-y-6 ${className}`}>
      {pendingBookings.length > 0 && (
        <div>
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-lg font-medium text-gray-900">Pending Voice Bookings</h3>
            {onRefresh && (
              <button
                onClick={onRefresh}
                className="text-sm text-blue-600 hover:text-blue-500"
              >
                Refresh
              </button>
            )}
          </div>
          <div className="space-y-4">
            {pendingBookings.map(booking => (
              <PendingBookingCard key={booking.id} booking={booking} />
            ))}
          </div>
        </div>
      )}

      {confirmedBookings.length > 0 && (
        <div>
          <h3 className="text-lg font-medium text-gray-900 mb-3">Recent Voice Bookings</h3>
          <div className="space-y-4">
            {confirmedBookings.slice(0, 5).map(booking => (
              <ConfirmedBookingCard key={booking.id} booking={booking} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}