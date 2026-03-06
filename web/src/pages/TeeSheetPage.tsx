import { useState } from 'react';
import { TeeSheet } from '../components/tee-sheet/TeeSheet';
import { BookingForm } from '../components/booking/BookingForm';
import { Modal } from '../components/ui/Modal';

export function TeeSheetPage() {
  const [bookingTeeTimeId, setBookingTeeTimeId] = useState<string | null>(null);

  // TODO: Get from course selector context
  const courseId = '1';

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
    </div>
  );
}
