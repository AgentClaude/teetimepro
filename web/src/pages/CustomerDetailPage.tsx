import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { AuditLog } from '../components/AuditLog';
import { GET_CUSTOMER } from '../graphql/queries';
import { UPDATE_CUSTOMER } from '../graphql/mutations';

export function CustomerDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data, loading } = useQuery(GET_CUSTOMER, { variables: { id } });
  const customer = data?.customer;

  const [editing, setEditing] = useState(false);
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [saved, setSaved] = useState(false);

  const [updateCustomer, { loading: saving }] = useMutation(UPDATE_CUSTOMER);

  useEffect(() => {
    if (customer) {
      setFirstName(customer.firstName || '');
      setLastName(customer.lastName || '');
      setEmail(customer.email || '');
      setPhone(customer.phone || '');
    }
  }, [customer]);

  async function handleSave() {
    try {
      const { data } = await updateCustomer({
        variables: { id, firstName, lastName, email, phone: phone || null },
      });
      if (data?.updateCustomer?.errors?.length) {
        alert(data.updateCustomer.errors.join(', '));
      } else {
        setEditing(false);
        setSaved(true);
        setTimeout(() => setSaved(false), 3000);
      }
    } catch {
      alert('Failed to update customer');
    }
  }

  const bookings = customer?.bookings || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="secondary" size="sm" onClick={() => navigate('/customers')}>
          &larr; Back
        </Button>
        <h1 className="text-2xl font-bold text-gray-900">Customer Detail</h1>
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading...</p>
      ) : !customer ? (
        <p className="text-sm text-gray-500">Customer not found.</p>
      ) : (
        <>
          {/* Customer Info */}
          <Card className="p-6">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-gray-900">Profile</h2>
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
                  <Button variant="secondary" size="sm" onClick={() => setEditing(true)}>Edit</Button>
                )}
              </div>
            </div>

            {editing ? (
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div>
                  <label className="block text-sm font-medium text-gray-700">First Name</label>
                  <input
                    type="text"
                    value={firstName}
                    onChange={(e) => setFirstName(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Last Name</label>
                  <input
                    type="text"
                    value={lastName}
                    onChange={(e) => setLastName(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Email</label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Phone</label>
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
                  />
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-x-8 gap-y-3 sm:grid-cols-4">
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Name</dt>
                  <dd className="mt-1 text-sm text-gray-900">{customer.fullName}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Email</dt>
                  <dd className="mt-1 text-sm text-gray-900">
                    {customer.email.endsWith('.local') ? '--' : customer.email}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Phone</dt>
                  <dd className="mt-1 text-sm text-gray-900">{customer.phone || '--'}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Role</dt>
                  <dd className="mt-1 text-sm text-gray-900 capitalize">{customer.role}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Total Bookings</dt>
                  <dd className="mt-1 text-sm text-gray-900">{customer.bookingsCount}</dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-gray-500">Customer Since</dt>
                  <dd className="mt-1 text-sm text-gray-900">{new Date(customer.createdAt).toLocaleDateString()}</dd>
                </div>
              </div>
            )}
          </Card>

          {/* Booking History */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Booking History</h2>
            {bookings.length === 0 ? (
              <p className="text-sm text-gray-500">No bookings yet.</p>
            ) : (
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead>
                    <tr>
                      <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Confirmation</th>
                      <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Date/Time</th>
                      <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Players</th>
                      <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Total</th>
                      <th className="px-3 py-2 text-left text-xs font-medium uppercase tracking-wider text-gray-500">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {bookings.map((b: { id: string; confirmationCode: string; teeTime?: { startTime: string; formattedTime?: string; startsAt?: string; course?: { name: string } }; playersCount: number; totalCents: number; status: string }) => (
                      <tr key={b.id} className="hover:bg-gray-50">
                        <td className="whitespace-nowrap px-3 py-2 font-mono text-sm font-medium text-gray-900">
                          {b.confirmationCode}
                        </td>
                        <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                          {b.teeTime?.formattedTime || (b.teeTime?.startsAt ? new Date(b.teeTime.startsAt).toLocaleString() : '—')}
                        </td>
                        <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                          {b.playersCount}
                        </td>
                        <td className="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
                          {b.totalCents != null ? `$${(b.totalCents / 100).toFixed(2)}` : '--'}
                        </td>
                        <td className="whitespace-nowrap px-3 py-2 text-sm">
                          <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${
                            b.status === 'confirmed' ? 'bg-green-100 text-green-800'
                              : b.status === 'cancelled' ? 'bg-red-100 text-red-800'
                              : 'bg-gray-100 text-gray-800'
                          }`}>
                            {b.status}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          {/* Audit Log */}
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-gray-900">Activity Log</h2>
            <AuditLog entries={customer.auditLog || []} />
          </Card>
        </>
      )}
    </div>
  );
}
