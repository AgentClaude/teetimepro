import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { AuditLog } from '../components/AuditLog';
import { GET_BOOKING } from '../graphql/queries';
import { UPDATE_BOOKING, CANCEL_BOOKING } from '../graphql/mutations';

const STATUS_OPTIONS = ['confirmed', 'checked_in', 'completed', 'cancelled', 'no_show'];

export function BookingDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, loading } = useQuery(GET_BOOKING, { variables: { id } });
  const booking = data?.booking;

  const [editing, setEditing] = useState(false);
  const [status, setStatus] = useState('');
  const [playersCount, setPlayersCount] = useState(1);
  const [notes, setNotes] = useState('');
  const [saved, setSaved] = useState(false);

  const [updateBooking, { loading: saving }] = useMutation(UPDATE_BOOKING, {
    refetchQueries: [{ query: GET_BOOKING, variables: { id } }],
  });
  const [cancelBooking, { loading: cancelling }] = useMutation(CANCEL_BOOKING, {
    refetchQueries: [{ query: GET_BOOKING, variables: { id } }],
  });

  useEffect(() => {
    if (booking) {
      setStatus(booking.status);
      setPlayersCount(booking.playersCount);
      setNotes(booking.notes || '');
    }
  }, [booking]);

  async function handleSave() {
    try {
      const { data } = await updateBooking({
        variables: { id, status, playersCount, notes: notes || null },
      });
      if (data?.updateBooking?.errors?.length) {
        alert(data.updateBooking.errors.join(', '));
      } else {
        setEditing(false);
        setSaved(true);
        setTimeout(() => setSaved(false), 3000);
      }
    } catch {
      alert('Failed to update booking');
    }
  }

  async function handleCancel() {
    if (!confirm('Are you sure you want to cancel this booking?')) return;
    try {
      const { data } = await cancelBooking({
        variables: { bookingId: id },
      });
      if (data?.cancelBooking?.errors?.length) {
        alert(data.cancelBooking.errors.join(', '));
      }
    } catch {
      alert('Failed to cancel booking');
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="secondary" size="sm" onClick={() => navigate('/bookings')}>
          &larr; Back
        </Button>
        <h1 className="text-2xl font-bold text-gray-900">Booking Detail</h1>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading...</p>
      ) : !booking ? (
        <p className="text-sm text-gray-500">Booking not found.</p>
      ) : (
        <>
          {/* Booking Info */}
          <Card className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">
                Booking {booking.confirmationCode}
              </h2>
              <div className="flex items-center gap-2">
                {saved && <span className="text-sm font-medium text-green-600">Saved</span>}
                {editing ? (
                  <>
                    <Button variant="secondary" size="sm" onClick={() => setEditing(false)}>Cancel</Button>
                    <Button variant="primary" size="sm" onClick={handleSave} disabled={saving}>
                      {saving ? 'Saving...' : 'Save'}
                    </Button>
                  </>
                ) : (
                  <>
                    <Button variant="secondary" size="sm" onClick={() => setEditing(true)}>Edit</Button>
                    {booking.cancellable && (
                      <Button variant="secondary" size="sm" onClick={handleCancel} disabled={cancelling}>
                        Cancel Booking
                      </Button>
                    )}
                  </>
                )}
              </div>
            </div>

            {editing ? (
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Status</label>
                  <select
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  >
                    {STATUS_OPTIONS.map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Players</label>
                  <input
                    type="number"
                    min={1}
                    max={5}
                    value={playersCount}
                    onChange={(e) => setPlayersCount(parseInt(e.target.value) || 1)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
                <div className="sm:col-span-2">
                  <label className="block text-sm font-medium text-gray-700">Notes</label>
                  <textarea
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    rows={3}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-x-8 gap-y-3 sm:grid-cols-4">
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Confirmation</dt>
                  <dd className="mt-1 font-mono text-sm font-semibold text-gray-900">{booking.confirmationCode}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Status</dt>
                  <dd className="mt-1">
                    <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                      booking.status === 'confirmed' ? 'bg-green-100 text-green-800'
                        : booking.status === 'cancelled' ? 'bg-red-100 text-red-800'
                        : booking.status === 'checked_in' ? 'bg-blue-100 text-blue-800'
                        : booking.status === 'completed' ? 'bg-gray-100 text-gray-800'
                        : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {booking.status}
                    </span>
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Tee Time</dt>
                  <dd className="mt-1 text-sm text-gray-900">
                    {booking.teeTime?.formattedTime || new Date(booking.teeTime?.startsAt).toLocaleString()}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Date</dt>
                  <dd className="mt-1 text-sm text-gray-900">
                    {new Date(booking.teeTime?.startsAt).toLocaleDateString()}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Players</dt>
                  <dd className="mt-1 text-sm text-gray-900">{booking.playersCount}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Total</dt>
                  <dd className="mt-1 text-sm text-gray-900">
                    {booking.totalCents != null ? `$${(booking.totalCents / 100).toFixed(2)}` : '--'}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Customer</dt>
                  <dd className="mt-1 text-sm text-gray-900">
                    <a href={`/customers/${booking.user.id}`} className="text-green-600 hover:text-green-800">
                      {booking.user.fullName}
                    </a>
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Booked</dt>
                  <dd className="mt-1 text-sm text-gray-900">{new Date(booking.createdAt).toLocaleString()}</dd>
                </div>
                {booking.notes && (
                  <div className="sm:col-span-4">
                    <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Notes</dt>
                    <dd className="mt-1 text-sm text-gray-900">{booking.notes}</dd>
                  </div>
                )}
                {booking.bookingPlayers.length > 0 && (
                  <div className="sm:col-span-4">
                    <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Players</dt>
                    <dd className="mt-1 text-sm text-gray-900">
                      {booking.bookingPlayers.map((p: { id: string; name: string }) => p.name).join(', ')}
                    </dd>
                  </div>
                )}
              </div>
            )}
          </Card>

          {/* Audit Log */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Activity Log</h2>
            <AuditLog entries={booking.auditLog || []} />
          </Card>
        </>
      )}
    </div>
  );
}
