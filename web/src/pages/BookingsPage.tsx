import { useState, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import { debounce } from 'lodash';
import { BookingList } from '../components/booking/BookingList';
import { useCourse } from '../contexts/CourseContext';
import { GET_BOOKINGS } from '../graphql/queries';
import { CANCEL_BOOKING } from '../graphql/mutations';
import { Input } from '../components/ui/Input';
import { Select } from '../components/ui/Select';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';
import { Card } from '../components/ui/Card';
import { Booking } from '../types';

interface BookingFilters {
  search: string;
  status: string;
  dateFrom: string;
  dateTo: string;
  bookingType: string;
}

interface CancelDialogState {
  isOpen: boolean;
  bookingId: string | null;
  confirmationCode: string | null;
}

const statusOptions = [
  { value: '', label: 'All Statuses' },
  { value: 'CONFIRMED', label: 'Confirmed' },
  { value: 'CHECKED_IN', label: 'Checked In' },
  { value: 'COMPLETED', label: 'Completed' },
  { value: 'CANCELLED', label: 'Cancelled' },
  { value: 'NO_SHOW', label: 'No Show' },
];

const bookingTypeOptions = [
  { value: '', label: 'All Types' },
  { value: 'online', label: 'Online' },
  { value: 'phone', label: 'Phone' },
  { value: 'walk_in', label: 'Walk-in' },
  { value: 'staff', label: 'Staff' },
];

export function BookingsPage() {
  const navigate = useNavigate();
  const { selectedCourseId } = useCourse();
  
  // Filters state
  const [filters, setFilters] = useState<BookingFilters>({
    search: '',
    status: '',
    dateFrom: '',
    dateTo: '',
    bookingType: '',
  });

  // Cancel dialog state
  const [cancelDialog, setCancelDialog] = useState<CancelDialogState>({
    isOpen: false,
    bookingId: null,
    confirmationCode: null,
  });
  const [cancelReason, setCancelReason] = useState('');
  const [includeRefund, setIncludeRefund] = useState(false);

  // Debounced search to avoid excessive API calls
  const debouncedSearch = useMemo(
    () => debounce((searchValue: string) => {
      setFilters(prev => ({ ...prev, search: searchValue }));
    }, 300),
    []
  );

  // GraphQL query
  const { data, loading, refetch } = useQuery(GET_BOOKINGS, {
    variables: {
      courseId: selectedCourseId || undefined,
      search: filters.search || undefined,
      status: filters.status || undefined,
      dateFrom: filters.dateFrom || undefined,
      dateTo: filters.dateTo || undefined,
      bookingType: filters.bookingType || undefined,
    },
    skip: !selectedCourseId,
    errorPolicy: 'all',
  });

  // Cancel booking mutation
  const [cancelBookingMutation, { loading: cancelling }] = useMutation(CANCEL_BOOKING, {
    onCompleted: () => {
      setCancelDialog({ isOpen: false, bookingId: null, confirmationCode: null });
      setCancelReason('');
      setIncludeRefund(false);
      refetch(); // Refresh the bookings list
    },
    onError: (error) => {
      console.error('Failed to cancel booking:', error);
      // TODO: Add proper error handling/toast notification
    },
  });

  // Format bookings for BookingList component
  const bookings = useMemo(() => {
    return (data?.bookings || []).map((booking: Booking) => ({
      ...booking,
      totalFormatted: booking.totalCents != null ? `$${(booking.totalCents / 100).toFixed(2)}` : '--',
    }));
  }, [data?.bookings]);

  // Handlers
  const handleSearchChange = useCallback((value: string) => {
    debouncedSearch(value);
  }, [debouncedSearch]);

  const handleFilterChange = useCallback((key: keyof BookingFilters, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  }, []);

  const handleClearFilters = useCallback(() => {
    setFilters({
      search: '',
      status: '',
      dateFrom: '',
      dateTo: '',
      bookingType: '',
    });
  }, []);

  const handleCancelBooking = useCallback((bookingId: string) => {
    const booking = data?.bookings?.find((b: Booking) => b.id === bookingId);
    if (booking) {
      setCancelDialog({
        isOpen: true,
        bookingId,
        confirmationCode: booking.confirmationCode,
      });
    }
  }, [data?.bookings]);

  const handleConfirmCancel = useCallback(async () => {
    if (!cancelDialog.bookingId) return;

    await cancelBookingMutation({
      variables: {
        bookingId: cancelDialog.bookingId,
        reason: cancelReason || undefined,
        refund: includeRefund,
      },
    });
  }, [cancelDialog.bookingId, cancelReason, includeRefund, cancelBookingMutation]);

  const handleExportCSV = useCallback(() => {
    if (!bookings.length) return;

    const headers = ['Confirmation Code', 'Date/Time', 'Golfer', 'Email', 'Players', 'Status', 'Total'];
    const csvContent = [
      headers.join(','),
      ...bookings.map((booking: Booking & { totalFormatted: string }) => [
        booking.confirmationCode,
        new Date(booking.teeTime.startsAt).toLocaleString(),
        `"${booking.user.fullName}"`,
        booking.user.email,
        booking.playersCount,
        booking.status,
        booking.totalFormatted,
      ].join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', `bookings_${new Date().toISOString().split('T')[0]}.csv`);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }, [bookings]);

  // Loading state
  if (loading && !data) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  // No course selected
  if (!selectedCourseId) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
        </div>
        <Card>
          <p className="text-gray-500 text-center py-8">
            Please select a course to view bookings.
          </p>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Bookings</h1>
        <div className="flex gap-2">
          <Button
            variant="outline"
            onClick={handleExportCSV}
            disabled={!bookings.length}
          >
            Export CSV
          </Button>
          {/* Future: Add pagination controls here */}
        </div>
      </div>

      {/* Search and Filters */}
      <Card>
        <div className="space-y-4">
          {/* Search Bar */}
          <div className="max-w-md">
            <Input
              type="text"
              placeholder="Search by confirmation code, golfer name, or email..."
              defaultValue={filters.search}
              onChange={(e) => handleSearchChange(e.target.value)}
              icon={
                <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              }
            />
          </div>

          {/* Filters Row */}
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
            <Select
              options={statusOptions}
              value={filters.status}
              onChange={(value) => handleFilterChange('status', value)}
              placeholder="Status"
            />
            
            <Input
              type="date"
              placeholder="From Date"
              value={filters.dateFrom}
              onChange={(e) => handleFilterChange('dateFrom', e.target.value)}
              label="From"
            />
            
            <Input
              type="date"
              placeholder="To Date"
              value={filters.dateTo}
              onChange={(e) => handleFilterChange('dateTo', e.target.value)}
              label="To"
            />
            
            <Select
              options={bookingTypeOptions}
              value={filters.bookingType}
              onChange={(value) => handleFilterChange('bookingType', value)}
              placeholder="Booking Type"
            />
            
            <div className="flex items-end">
              <Button
                variant="outline"
                onClick={handleClearFilters}
                className="w-full"
              >
                Clear Filters
              </Button>
            </div>
          </div>
        </div>
      </Card>

      {/* Results */}
      {loading ? (
        <div className="flex items-center justify-center py-8">
          <LoadingSpinner />
        </div>
      ) : (
        <BookingList
          bookings={bookings}
          onViewBooking={(id) => navigate(`/bookings/${id}`)}
          onCancelBooking={handleCancelBooking}
        />
      )}

      {/* Cancel Booking Dialog */}
      <Modal
        isOpen={cancelDialog.isOpen}
        onClose={() => setCancelDialog({ isOpen: false, bookingId: null, confirmationCode: null })}
        title="Cancel Booking"
        size="md"
      >
        <div className="space-y-4">
          <p className="text-gray-700">
            Are you sure you want to cancel booking{' '}
            <span className="font-mono font-semibold">{cancelDialog.confirmationCode}</span>?
          </p>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cancellation Reason (Optional)
            </label>
            <textarea
              className="w-full rounded-lg border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              rows={3}
              placeholder="Enter reason for cancellation..."
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
            />
          </div>

          <div className="flex items-center">
            <input
              type="checkbox"
              id="refund"
              checked={includeRefund}
              onChange={(e) => setIncludeRefund(e.target.checked)}
              className="mr-2"
            />
            <label htmlFor="refund" className="text-sm text-gray-700">
              Process refund for this cancellation
            </label>
          </div>

          <div className="flex justify-end gap-3 pt-4">
            <Button
              variant="outline"
              onClick={() => setCancelDialog({ isOpen: false, bookingId: null, confirmationCode: null })}
              disabled={cancelling}
            >
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={handleConfirmCancel}
              disabled={cancelling}
            >
              {cancelling ? 'Cancelling...' : 'Confirm Cancel'}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}