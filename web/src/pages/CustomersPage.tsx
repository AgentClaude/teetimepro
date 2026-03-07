import { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { CustomerFilters, CustomerFilterValues, INITIAL_FILTERS } from '../components/customers/CustomerFilters';
import { CustomerPagination } from '../components/customers/CustomerPagination';
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

interface CustomersData {
  customers: {
    nodes: Customer[];
    totalCount: number;
    page: number;
    perPage: number;
    totalPages: number;
  };
}

const PER_PAGE = 25;

export function CustomersPage() {
  const [filters, setFilters] = useState<CustomerFilterValues>(INITIAL_FILTERS);
  const [page, setPage] = useState(1);

  // Debounce search to avoid excessive queries
  const [debouncedSearch, setDebouncedSearch] = useState('');
  useMemo(() => {
    const timer = setTimeout(() => setDebouncedSearch(filters.search), 300);
    return () => clearTimeout(timer);
  }, [filters.search]);

  const variables = useMemo(() => ({
    search: debouncedSearch || undefined,
    role: filters.role || undefined,
    membershipTier: filters.membershipTier || undefined,
    loyaltyTier: filters.loyaltyTier || undefined,
    minBookings: filters.minBookings ? parseInt(filters.minBookings, 10) : undefined,
    maxBookings: filters.maxBookings ? parseInt(filters.maxBookings, 10) : undefined,
    sortBy: filters.sortBy || undefined,
    sortDir: filters.sortDir || undefined,
    page,
    perPage: PER_PAGE,
  }), [debouncedSearch, filters.role, filters.membershipTier, filters.loyaltyTier, filters.minBookings, filters.maxBookings, filters.sortBy, filters.sortDir, page]);

  const { data, loading } = useQuery<CustomersData>(GET_CUSTOMERS, { variables });

  const customers = data?.customers?.nodes || [];
  const totalCount = data?.customers?.totalCount ?? 0;
  const totalPages = data?.customers?.totalPages ?? 1;
  const currentPage = data?.customers?.page ?? page;

  function handleFilterChange(newFilters: CustomerFilterValues) {
    setFilters(newFilters);
    setPage(1); // Reset to first page on filter change
  }

  function roleBadgeVariant(role: string) {
    switch (role) {
      case 'manager': case 'admin': case 'owner': return 'info' as const;
      case 'staff': case 'pro_shop': return 'warning' as const;
      default: return 'neutral' as const;
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-rough-900">Customers</h1>
      </div>

      <CustomerFilters
        filters={filters}
        onChange={handleFilterChange}
        totalCount={totalCount}
      />

      {loading ? (
        <p className="text-sm text-rough-500">Loading customers...</p>
      ) : customers.length === 0 ? (
        <Card>
          <div className="py-8 text-center">
            <p className="text-rough-500">
              {debouncedSearch || filters.role || filters.membershipTier || filters.loyaltyTier
                ? 'No customers match your filters.'
                : 'No customers yet. Customers are created automatically when bookings are made.'}
            </p>
          </div>
        </Card>
      ) : (
        <>
          <div className="overflow-hidden rounded-lg bg-white shadow-sm">
            <table className="min-w-full divide-y divide-rough-200">
              <thead className="bg-rough-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Name</th>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Email</th>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Phone</th>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Role</th>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Bookings</th>
                  <th className="px-4 py-3 text-left text-xs font-medium uppercase tracking-wider text-rough-500">Since</th>
                  <th className="px-4 py-3 text-right text-xs font-medium uppercase tracking-wider text-rough-500" />
                </tr>
              </thead>
              <tbody className="divide-y divide-rough-100">
                {customers.map((c) => (
                  <tr key={c.id} className="hover:bg-rough-50 transition-colors">
                    <td className="whitespace-nowrap px-4 py-3 text-sm font-medium text-rough-900">
                      <Link to={`/customers/${c.id}`} className="hover:text-fairway-600">
                        {c.fullName}
                      </Link>
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-700">
                      {c.email.endsWith('.local') ? <span className="text-rough-400">—</span> : c.email}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-700">
                      {c.phone || <span className="text-rough-400">—</span>}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-sm">
                      <Badge variant={roleBadgeVariant(c.role)} size="sm">
                        {c.role.replace('_', ' ')}
                      </Badge>
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-700">
                      {c.bookingsCount}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-sm text-rough-500">
                      {new Date(c.createdAt).toLocaleDateString()}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-right text-sm">
                      <Link
                        to={`/customers/${c.id}`}
                        className="font-medium text-fairway-600 hover:text-fairway-800"
                      >
                        View
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <CustomerPagination
            page={currentPage}
            totalPages={totalPages}
            totalCount={totalCount}
            perPage={PER_PAGE}
            onPageChange={setPage}
          />
        </>
      )}
    </div>
  );
}
