import { useState } from 'react';
import { format, addDays, subDays } from 'date-fns';
import { ChevronLeftIcon, ChevronRightIcon } from '@heroicons/react/24/outline';
import { TeeTimeSlot } from './TeeTimeSlot';
import { useTeeSheet } from '../../hooks/useTeeSheet';
import { LoadingSpinner } from '../ui/LoadingSpinner';

interface TeeSheetProps {
  courseId: string;
  onBookTeeTime?: (teeTimeId: string) => void;
  onEditTeeTime?: (teeTimeId: string) => void;
}

export function TeeSheet({ courseId, onBookTeeTime, onEditTeeTime }: TeeSheetProps) {
  const [selectedDate, setSelectedDate] = useState(new Date());
  const { teeSheet, loading, error } = useTeeSheet(courseId, format(selectedDate, 'yyyy-MM-dd'));

  const goToPreviousDay = () => setSelectedDate((d) => subDays(d, 1));
  const goToNextDay = () => setSelectedDate((d) => addDays(d, 1));
  const goToToday = () => setSelectedDate(new Date());

  if (error) {
    return (
      <div className="rounded-lg bg-red-50 p-4 text-red-700">
        Failed to load tee sheet: {error.message}
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Date Navigation */}
      <div className="flex items-center justify-between rounded-lg bg-white p-4 shadow-sm">
        <button
          onClick={goToPreviousDay}
          className="rounded-md p-2 hover:bg-gray-100"
        >
          <ChevronLeftIcon className="h-5 w-5" />
        </button>

        <div className="flex items-center gap-3">
          <h2 className="text-lg font-semibold text-gray-900">
            {format(selectedDate, 'EEEE, MMMM d, yyyy')}
          </h2>
          <button
            onClick={goToToday}
            className="rounded-md bg-green-100 px-3 py-1 text-sm font-medium text-green-700 hover:bg-green-200"
          >
            Today
          </button>
        </div>

        <button
          onClick={goToNextDay}
          className="rounded-md p-2 hover:bg-gray-100"
        >
          <ChevronRightIcon className="h-5 w-5" />
        </button>
      </div>

      {/* Tee Sheet Grid */}
      {loading ? (
        <div className="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </div>
      ) : (
        <div className="overflow-hidden rounded-lg bg-white shadow-sm">
          {/* Header */}
          <div className="grid grid-cols-12 gap-px border-b bg-gray-100 px-4 py-3 text-sm font-medium text-gray-600">
            <div className="col-span-2">Time</div>
            <div className="col-span-3">Players</div>
            <div className="col-span-2">Status</div>
            <div className="col-span-2">Rate</div>
            <div className="col-span-3 text-right">Actions</div>
          </div>

          {/* Tee Time Rows */}
          <div className="divide-y divide-gray-100">
            {teeSheet?.teeTimes && teeSheet.teeTimes.length > 0 ? (
              teeSheet.teeTimes.map((teeTime) => (
                <TeeTimeSlot
                  key={teeTime.id}
                  teeTime={teeTime}
                  onBook={() => onBookTeeTime?.(teeTime.id)}
                  onEdit={() => onEditTeeTime?.(teeTime.id)}
                />
              ))
            ) : (
              <div className="px-4 py-12 text-center text-gray-500">
                No tee times configured for this date.
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
