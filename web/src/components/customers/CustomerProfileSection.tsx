import { useState, useEffect } from 'react';
import { useMutation } from '@apollo/client';
import { Card, CardHeader } from '../ui/Card';
import { Button } from '../ui/Button';
import { Badge } from '../ui/Badge';
import { UPDATE_CUSTOMER } from '../../graphql/mutations';

interface CustomerProfileSectionProps {
  customer: {
    id: string;
    firstName: string;
    lastName: string;
    fullName: string;
    email: string;
    phone: string | null;
    role: string;
    bookingsCount: number;
    createdAt: string;
    golferProfile?: {
      handicapIndex: number | null;
      homeCourse: string | null;
      preferredTee: string | null;
    } | null;
    membership?: {
      id: string;
      tier: string;
      status: string;
      startsAt: string;
      endsAt: string;
      daysRemaining: number;
      accountBalanceCents: number;
      creditLimitCents: number;
      availableCreditCents: number;
    } | null;
  };
  onUpdate?: () => void;
}

export function CustomerProfileSection({ customer, onUpdate }: CustomerProfileSectionProps) {
  const [editing, setEditing] = useState(false);
  const [firstName, setFirstName] = useState(customer.firstName);
  const [lastName, setLastName] = useState(customer.lastName);
  const [email, setEmail] = useState(customer.email);
  const [phone, setPhone] = useState(customer.phone || '');
  const [saved, setSaved] = useState(false);

  const [updateCustomer, { loading: saving }] = useMutation(UPDATE_CUSTOMER);

  useEffect(() => {
    setFirstName(customer.firstName);
    setLastName(customer.lastName);
    setEmail(customer.email);
    setPhone(customer.phone || '');
  }, [customer]);

  async function handleSave() {
    try {
      const { data } = await updateCustomer({
        variables: { id: customer.id, firstName, lastName, email, phone: phone || null },
      });
      if (data?.updateCustomer?.errors?.length) {
        alert(data.updateCustomer.errors.join(', '));
      } else {
        setEditing(false);
        setSaved(true);
        setTimeout(() => setSaved(false), 3000);
        onUpdate?.();
      }
    } catch {
      alert('Failed to update customer');
    }
  }

  const membership = customer.membership;

  return (
    <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
      {/* Profile Info */}
      <Card>
        <CardHeader
          title="Profile"
          action={
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
          }
        />

        {editing ? (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="block text-sm font-medium text-rough-700">First Name</label>
              <input
                type="text"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                className="mt-1 block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500 text-sm"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-rough-700">Last Name</label>
              <input
                type="text"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                className="mt-1 block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500 text-sm"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-rough-700">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500 text-sm"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-rough-700">Phone</label>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="mt-1 block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500 text-sm"
              />
            </div>
          </div>
        ) : (
          <dl className="grid grid-cols-2 gap-x-6 gap-y-4">
            <div>
              <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Name</dt>
              <dd className="mt-1 text-sm text-rough-900">{customer.fullName}</dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Email</dt>
              <dd className="mt-1 text-sm text-rough-900">
                {customer.email.endsWith('.local') ? '—' : customer.email}
              </dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Phone</dt>
              <dd className="mt-1 text-sm text-rough-900">{customer.phone || '—'}</dd>
            </div>
            <div>
              <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Role</dt>
              <dd className="mt-1 text-sm text-rough-900 capitalize">{customer.role}</dd>
            </div>
            {customer.golferProfile && (
              <>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Handicap</dt>
                  <dd className="mt-1 text-sm text-rough-900">
                    {customer.golferProfile.handicapIndex != null
                      ? customer.golferProfile.handicapIndex
                      : '—'}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Preferred Tee</dt>
                  <dd className="mt-1 text-sm text-rough-900 capitalize">
                    {customer.golferProfile.preferredTee || '—'}
                  </dd>
                </div>
              </>
            )}
          </dl>
        )}
      </Card>

      {/* Membership Info */}
      <Card>
        <CardHeader title="Membership" />
        {membership && membership.status === 'active' ? (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Badge variant={
                  membership.tier === 'platinum' ? 'info'
                    : membership.tier === 'gold' ? 'warning'
                    : membership.tier === 'silver' ? 'secondary'
                    : 'neutral'
                }>
                  {membership.tier.charAt(0).toUpperCase() + membership.tier.slice(1)}
                </Badge>
                <Badge variant="success">Active</Badge>
              </div>
              <span className="text-sm text-rough-500">{membership.daysRemaining} days remaining</span>
            </div>

            <div className="rounded-lg bg-rough-50 p-4">
              <dl className="grid grid-cols-2 gap-4">
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Valid Until</dt>
                  <dd className="mt-1 text-sm font-medium text-rough-900">
                    {new Date(membership.endsAt).toLocaleDateString()}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Account Balance</dt>
                  <dd className="mt-1 text-sm font-medium text-rough-900">
                    ${(membership.accountBalanceCents / 100).toFixed(2)}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Credit Limit</dt>
                  <dd className="mt-1 text-sm font-medium text-rough-900">
                    ${(membership.creditLimitCents / 100).toFixed(2)}
                  </dd>
                </div>
                <div>
                  <dt className="text-xs font-medium uppercase tracking-wider text-rough-500">Available Credit</dt>
                  <dd className="mt-1 text-sm font-medium text-rough-900">
                    ${(membership.availableCreditCents / 100).toFixed(2)}
                  </dd>
                </div>
              </dl>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <p className="text-sm text-rough-500">No active membership</p>
            <p className="text-xs text-rough-400 mt-1">
              {membership ? `Previous membership ${membership.status}` : 'Customer has not joined a membership plan'}
            </p>
          </div>
        )}
      </Card>
    </div>
  );
}
