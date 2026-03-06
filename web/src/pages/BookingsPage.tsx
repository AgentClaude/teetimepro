import { useNavigate } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { BookingList } from '../components/booking/BookingList';
import { useCourse } from '../contexts/CourseContext';
import { GET_BOOKINGS } from '../graphql/queries';

export function BookingsPage() {
  const navigate = useNavigate();
  const { selectedCourseId } = useCourse();
  const { data, loading } = useQuery(GET_BOOKINGS, {
    variables: { courseId: selectedCourseId || undefined },
    skip: !selectedCourseId,
  });

  const bookings = (data?.bookings || []).map((b: any) => ({
    ...b,
    totalFormatted: b.totalCents != null ? `$${(b.totalCents / 100).toFixed(2)}` : '--',
    teeTime: {
      ...b.teeTime,
      course: { name: b.teeTime?.formattedTime ? '' : '' },
    },
  }));

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading bookings...</p>
      ) : (
        <BookingList
          bookings={bookings}
          onViewBooking={(id) => navigate(`/bookings/${id}`)}
          onCancelBooking={(id) => navigate(`/bookings/${id}`)}
        />
      )}
    </div>
  );
}
