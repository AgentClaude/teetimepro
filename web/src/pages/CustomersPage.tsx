import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { GET_CUSTOMERS } from '../graphql/queries';

interface Customer {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName: string;
  phone: string | null;
  role: string;
  bookingsCount: number;
  createdAt: string;
}

export function CustomersPage() {
  const [search, setSearch] = useState('');
  const { data, loading } = useQuery(GET_CUSTOMERS, {
    variables: { search: search || undefined },
  });
  const customers: Customer[] = data?.customers || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Customers</h1>
        <span className="text-sm text-gray-500">{customers.length} customers</span>
      </div>

      {/* Search */}
      <div>
        <input
          type="text"
          placeholder="Search by name, email, or phone..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="block w-full max-w-md rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
        />
      </div>

      {loading ? (
        <p className="text-sm text-gray-500">Loading customers...</p>
      ) : customers.length === 0 ? (
        <Card className="p-8 text-center">
          <p className="text-gray-500">
            {search ? 'No customers match your search.' : 'No customers yet. Customers are created automatically when bookings are made.'}
          </p>
        </Card>
      ) : (
        <div className="overflow-hidden rounded-lg bg-white shadow-sm">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Name</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Email</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Phone</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Bookings</th>
                <th className="px-4 py-3 text-left text-xs font-medium uppercase text-gray-500">Since</th>
                <th className="px-4 py-3 text-right text-xs font-medium uppercase text-gray-500"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {customers.map((c) => (
                <tr key={c.id} className="hover:bg-gray-50">
                  <td className="whitespace-nowrap px-4 py-3 text-sm font-medium text-gray-900">
                    {c.fullName}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                    {c.email.endsWith('.local') ? <span className="text-gray-400">--</span> : c.email}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                    {c.phone || <span className="text-gray-400">--</span>}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-700">
                    {c.bookingsCount}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-sm text-gray-500">
                    {new Date(c.createdAt).toLocaleDateString()}
                  </td>
                  <td className="whitespace-nowrap px-4 py-3 text-right text-sm">
                    <Link
                      to={`/customers/${c.id}`}
                      className="font-medium text-green-600 hover:text-green-800"
                    >
                      View
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
