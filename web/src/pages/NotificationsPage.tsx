import { Link } from 'react-router-dom';
import { Card } from '../components/ui/Card';
import { useNotifications, type BookingNotification } from '../hooks/useNotifications';

export function NotificationsPage() {
  const { notifications, connected, clearNotifications } = useNotifications();

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <h1 className="text-2xl font-bold text-gray-900">Live Notifications</h1>
          <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ${
            connected ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            <span className={`h-1.5 w-1.5 rounded-full ${connected ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`} />
            {connected ? 'Connected' : 'Disconnected'}
          </span>
        </div>
        {notifications.length > 0 && (
          <button
            onClick={clearNotifications}
            className="text-sm text-gray-500 hover:text-gray-700"
          >
            Clear all
          </button>
        )}
      </div>

      {notifications.length === 0 ? (
        <Card className="p-12 text-center">
          <div className="text-gray-400">
            <svg className="mx-auto h-12 w-12 mb-3" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
            </svg>
            <p className="text-sm font-medium">No notifications yet</p>
            <p className="mt-1 text-xs">New booking and cancellation events will appear here in real time.</p>
          </div>
        </Card>
      ) : (
        <div className="space-y-3">
          {notifications.map((notification, i) => (
            <NotificationCard key={`${notification.booking.id}-${notification.timestamp}-${i}`} notification={notification} />
          ))}
        </div>
      )}
    </div>
  );
}

function NotificationCard({ notification }: { notification: BookingNotification }) {
  const isCreated = notification.type === 'booking.created';
  const b = notification.booking;

  return (
    <Link
      to={`/bookings/${b.id}`}
      className="block transition hover:ring-2 hover:ring-green-200 rounded-lg"
    >
      <Card className="p-4">
        <div className="flex items-start justify-between">
          <div className="flex items-start gap-3">
            <div className={`mt-0.5 flex h-8 w-8 items-center justify-center rounded-full ${
              isCreated ? 'bg-green-100' : 'bg-red-100'
            }`}>
              {isCreated ? (
                <svg className="h-4 w-4 text-green-600" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
                </svg>
              ) : (
                <svg className="h-4 w-4 text-red-600" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18 18 6M6 6l12 12" />
                </svg>
              )}
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-gray-900">
                  {isCreated ? 'New Booking' : 'Booking Cancelled'}
                </span>
                <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                  isCreated ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                }`}>
                  {b.confirmation_code}
                </span>
              </div>
              <p className="mt-0.5 text-sm text-gray-600">
                <span className="font-medium">{b.customer_name}</span>
                {' — '}
                {b.players_count} player{b.players_count > 1 ? 's' : ''}
                {' at '}
                {b.tee_time}
                {' on '}
                {new Date(b.date + 'T00:00:00').toLocaleDateString()}
              </p>
              <p className="mt-0.5 text-xs text-gray-500">
                {b.course_name}
                {b.total_cents > 0 && ` — $${(b.total_cents / 100).toFixed(2)}`}
              </p>
              {!isCreated && b.cancellation_reason && (
                <p className="mt-1 text-xs text-red-600">Reason: {b.cancellation_reason}</p>
              )}
            </div>
          </div>
          <span className="text-xs text-gray-400 whitespace-nowrap">
            {new Date(notification.timestamp).toLocaleTimeString()}
          </span>
        </div>
      </Card>
    </Link>
  );
}
