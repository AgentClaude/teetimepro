import { CheckCircleIcon } from '@heroicons/react/24/solid';
import { Button } from '../ui/Button';

interface BookingConfirmationProps {
  booking: {
    confirmationCode: string;
    courseName: string;
    dateTime: string;
    playersCount: number;
    totalFormatted: string;
  };
  onClose: () => void;
}

export function BookingConfirmation({ booking, onClose }: BookingConfirmationProps) {
  return (
    <div className="flex flex-col items-center space-y-6 py-4 text-center">
      <CheckCircleIcon className="h-16 w-16 text-green-500" />

      <div>
        <h3 className="text-xl font-bold text-gray-900">Booking Confirmed!</h3>
        <p className="mt-1 text-sm text-gray-500">A confirmation has been sent to your email and phone.</p>
      </div>

      <div className="w-full rounded-lg bg-gray-50 p-4">
        <div className="space-y-2 text-left text-sm">
          <div className="flex justify-between">
            <span className="text-gray-500">Confirmation #</span>
            <span className="font-mono font-bold text-gray-900">{booking.confirmationCode}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-500">Course</span>
            <span className="text-gray-900">{booking.courseName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-500">Date & Time</span>
            <span className="text-gray-900">{booking.dateTime}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-500">Players</span>
            <span className="text-gray-900">{booking.playersCount}</span>
          </div>
          <div className="flex justify-between border-t pt-2">
            <span className="font-medium text-gray-700">Total</span>
            <span className="font-bold text-green-600">{booking.totalFormatted}</span>
          </div>
        </div>
      </div>

      <Button variant="primary" onClick={onClose} className="w-full">
        Done
      </Button>
    </div>
  );
}
