import { useState } from 'react';
import { TeeSheet } from '../components/tee-sheet/TeeSheet';
import { BookingForm } from '../components/booking/BookingForm';
import { TurnOrderModal } from '../components/turn-order/TurnOrderModal';
import { Modal } from '../components/ui/Modal';
import { useCourse } from '../contexts/CourseContext';

interface TurnOrderTarget {
  bookingId: string;
  golferName: string;
}

export function TeeSheetPage() {
  const [bookingTeeTimeId, setBookingTeeTimeId] = useState<string | null>(null);
  const [turnOrderTarget, setTurnOrderTarget] = useState<TurnOrderTarget | null>(null);
  const { selectedCourseId: courseId } = useCourse();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Tee Sheet</h1>
      </div>

      <TeeSheet
        courseId={courseId}
        onBookTeeTime={(id) => setBookingTeeTimeId(id)}
        onEditTeeTime={(id) => {
          // TODO: Open edit modal
          console.log('Edit tee time:', id);
        }}
        onOrderFood={(bookingId, golferName) =>
          setTurnOrderTarget({ bookingId, golferName })
        }
      />

      {/* Booking Modal */}
      <Modal
        isOpen={bookingTeeTimeId !== null}
        onClose={() => setBookingTeeTimeId(null)}
        title="Book Tee Time"
      >
        {bookingTeeTimeId && (
          <BookingForm
            teeTime={{
              id: bookingTeeTimeId,
              startsAt: '',
              availableSpots: 4,
              priceCents: 5500,
              courseName: 'Course',
            }}
            onSubmit={(data) => {
              console.log('Book:', data);
              setBookingTeeTimeId(null);
            }}
            onCancel={() => setBookingTeeTimeId(null)}
          />
        )}
      </Modal>

      {/* Turn Order Modal */}
      {turnOrderTarget && (
        <TurnOrderModal
          isOpen={true}
          onClose={() => setTurnOrderTarget(null)}
          bookingId={turnOrderTarget.bookingId}
          golferName={turnOrderTarget.golferName}
          teeTime="" // Time is shown in the modal from booking context
          onSuccess={() => {
            // Refetch tee sheet data would happen via Apollo cache
          }}
        />
      )}
    </div>
  );
}
