import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@apollo/client';
import { Card, CardHeader } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { AuditLog } from '../components/AuditLog';
import { CustomerProfileSection } from '../components/customers/CustomerProfileSection';
import { CustomerBookingsSection } from '../components/customers/CustomerBookingsSection';
import { CustomerLoyaltySection } from '../components/customers/CustomerLoyaltySection';
import { CustomerQuickActions } from '../components/customers/CustomerQuickActions';
import { GET_CUSTOMER } from '../graphql/queries';

type Tab = 'overview' | 'bookings' | 'loyalty' | 'activity';

export function CustomerDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<Tab>('overview');
  const { data, loading, refetch } = useQuery(GET_CUSTOMER, { variables: { id } });
  const customer = data?.customer;

  const tabs: { key: Tab; label: string; count?: number }[] = [
    { key: 'overview', label: 'Overview' },
    { key: 'bookings', label: 'Bookings', count: customer?.bookingsCount },
    { key: 'loyalty', label: 'Loyalty', count: customer?.loyaltyAccount?.pointsBalance },
    { key: 'activity', label: 'Activity' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="secondary" size="sm" onClick={() => navigate('/customers')}>
            &larr; Back
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-rough-900">
              {loading ? 'Loading...' : customer?.fullName || 'Customer Not Found'}
            </h1>
            {customer && (
              <p className="text-sm text-rough-500">
                Customer since {new Date(customer.createdAt).toLocaleDateString()}
                {customer.membership && (
                  <> · <span className="capitalize font-medium text-rough-700">{customer.membership.tier}</span> member</>
                )}
              </p>
            )}
          </div>
        </div>
        {customer && (
          <CustomerQuickActions customer={customer} />
        )}
      </div>

      {loading ? (
        <p className="text-sm text-rough-500">Loading customer details...</p>
      ) : !customer ? (
        <Card>
          <p className="text-sm text-rough-500">Customer not found.</p>
        </Card>
      ) : (
        <>
          {/* Stats Bar */}
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <Card>
              <p className="text-sm text-rough-500">Total Bookings</p>
              <p className="text-2xl font-bold text-rough-900 mt-1">{customer.bookingsCount}</p>
            </Card>
            <Card>
              <p className="text-sm text-rough-500">Upcoming</p>
              <p className="text-2xl font-bold text-rough-900 mt-1">{customer.upcomingBookings?.length || 0}</p>
            </Card>
            <Card>
              <p className="text-sm text-rough-500">Membership</p>
              <p className="text-2xl font-bold text-rough-900 mt-1 capitalize">
                {customer.membership?.status === 'active' ? customer.membership.tier : 'None'}
              </p>
              {customer.membership?.status === 'active' && (
                <p className="text-xs text-rough-500 mt-1">{customer.membership.daysRemaining} days left</p>
              )}
            </Card>
            <Card>
              <p className="text-sm text-rough-500">Loyalty Points</p>
              <p className="text-2xl font-bold text-rough-900 mt-1">
                {customer.loyaltyAccount?.pointsBalance?.toLocaleString() || '—'}
              </p>
              {customer.loyaltyAccount && (
                <p className="text-xs text-rough-500 mt-1 capitalize">{customer.loyaltyAccount.tierName} tier</p>
              )}
            </Card>
          </div>

          {/* Tabs */}
          <div className="border-b border-rough-200">
            <nav className="-mb-px flex gap-6">
              {tabs.map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`py-3 text-sm font-medium border-b-2 transition-colors ${
                    activeTab === tab.key
                      ? 'border-fairway-600 text-fairway-600'
                      : 'border-transparent text-rough-500 hover:text-rough-700 hover:border-rough-300'
                  }`}
                >
                  {tab.label}
                  {tab.count !== undefined && tab.count > 0 && (
                    <span className="ml-2 rounded-full bg-rough-100 px-2 py-0.5 text-xs text-rough-600">
                      {typeof tab.count === 'number' && tab.count > 999
                        ? `${(tab.count / 1000).toFixed(1)}k`
                        : tab.count}
                    </span>
                  )}
                </button>
              ))}
            </nav>
          </div>

          {/* Tab Content */}
          {activeTab === 'overview' && (
            <div className="space-y-6">
              <CustomerProfileSection customer={customer} onUpdate={refetch} />
              {customer.upcomingBookings?.length > 0 && (
                <Card>
                  <CardHeader
                    title="Upcoming Bookings"
                    action={
                      <Button variant="ghost" size="sm" onClick={() => setActiveTab('bookings')}>
                        View all →
                      </Button>
                    }
                  />
                  <CustomerBookingsSection
                    bookings={customer.upcomingBookings.slice(0, 5)}
                    emptyMessage="No upcoming bookings"
                  />
                </Card>
              )}
              {customer.loyaltyAccount && (
                <CustomerLoyaltySection loyaltyAccount={customer.loyaltyAccount} compact />
              )}
            </div>
          )}

          {activeTab === 'bookings' && (
            <div className="space-y-6">
              <Card>
                <CardHeader title="Upcoming Bookings" />
                <CustomerBookingsSection
                  bookings={customer.upcomingBookings || []}
                  emptyMessage="No upcoming bookings"
                />
              </Card>
              <Card>
                <CardHeader title="Past Bookings" />
                <CustomerBookingsSection
                  bookings={customer.pastBookings || []}
                  emptyMessage="No past bookings"
                />
              </Card>
            </div>
          )}

          {activeTab === 'loyalty' && (
            <CustomerLoyaltySection loyaltyAccount={customer.loyaltyAccount} />
          )}

          {activeTab === 'activity' && (
            <Card>
              <CardHeader title="Activity Log" />
              <AuditLog entries={customer.auditLog || []} />
            </Card>
          )}
        </>
      )}
    </div>
  );
}
