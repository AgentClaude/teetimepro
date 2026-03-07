import { useState } from 'react';
import { 
  CalendarDaysIcon, 
  LinkIcon, 
  XMarkIcon,
  CheckCircleIcon,
  ExclamationTriangleIcon 
} from '@heroicons/react/24/outline';
import { Button } from '../ui/Button';
import { Switch } from '../ui/Switch';

interface CalendarConnection {
  id: string;
  provider: 'google' | 'apple';
  enabled: boolean;
  calendarName: string;
  createdAt: string;
}

interface CalendarSyncSettingsProps {
  connections: CalendarConnection[];
  onConnect: (provider: 'google' | 'apple') => Promise<void>;
  onDisconnect: (provider: 'google' | 'apple') => Promise<void>;
  onToggle: (provider: 'google' | 'apple', enabled: boolean) => Promise<void>;
}

export function CalendarSyncSettings({ 
  connections, 
  onConnect, 
  onDisconnect, 
  onToggle 
}: CalendarSyncSettingsProps) {
  const [loading, setLoading] = useState<string | null>(null);

  const getConnection = (provider: 'google' | 'apple') => 
    connections.find(c => c.provider === provider);

  const handleConnect = async (provider: 'google' | 'apple') => {
    setLoading(`connect-${provider}`);
    try {
      await onConnect(provider);
    } finally {
      setLoading(null);
    }
  };

  const handleDisconnect = async (provider: 'google' | 'apple') => {
    setLoading(`disconnect-${provider}`);
    try {
      await onDisconnect(provider);
    } finally {
      setLoading(null);
    }
  };

  const handleToggle = async (provider: 'google' | 'apple', enabled: boolean) => {
    setLoading(`toggle-${provider}`);
    try {
      await onToggle(provider, enabled);
    } finally {
      setLoading(null);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900">Calendar Sync</h3>
        <p className="mt-1 text-sm text-gray-500">
          Automatically sync your golf bookings to your calendar
        </p>
      </div>

      <div className="space-y-4">
        {/* Google Calendar */}
        <CalendarProviderCard
          provider="google"
          displayName="Google Calendar"
          connection={getConnection('google')}
          onConnect={() => handleConnect('google')}
          onDisconnect={() => handleDisconnect('google')}
          onToggle={(enabled) => handleToggle('google', enabled)}
          loading={loading?.includes('google') ?? false}
        />

        {/* Apple Calendar (iCal) */}
        <CalendarProviderCard
          provider="apple"
          displayName="Apple Calendar"
          connection={getConnection('apple')}
          onConnect={() => handleConnect('apple')}
          onDisconnect={() => handleDisconnect('apple')}
          onToggle={(enabled) => handleToggle('apple', enabled)}
          loading={loading?.includes('apple') ?? false}
          isComingSoon={true}
        />
      </div>

      <div className="rounded-lg bg-amber-50 p-4">
        <div className="flex">
          <ExclamationTriangleIcon className="h-5 w-5 text-amber-400" />
          <div className="ml-3">
            <h4 className="text-sm font-medium text-amber-800">
              Manual Calendar Option
            </h4>
            <p className="mt-1 text-sm text-amber-700">
              You can always download an ICS file for any booking to manually add it to any calendar app.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

interface CalendarProviderCardProps {
  provider: 'google' | 'apple';
  displayName: string;
  connection?: CalendarConnection;
  onConnect: () => void;
  onDisconnect: () => void;
  onToggle: (enabled: boolean) => void;
  loading: boolean;
  isComingSoon?: boolean;
}

function CalendarProviderCard({
  provider: _provider,
  displayName,
  connection,
  onConnect,
  onDisconnect,
  onToggle,
  loading,
  isComingSoon = false
}: CalendarProviderCardProps) {
  return (
    <div className="flex items-center justify-between rounded-lg border border-gray-200 p-4">
      <div className="flex items-center space-x-3">
        <div className="flex-shrink-0">
          <CalendarDaysIcon className="h-6 w-6 text-gray-400" />
        </div>
        <div>
          <div className="flex items-center space-x-2">
            <h4 className="text-sm font-medium text-gray-900">{displayName}</h4>
            {isComingSoon && (
              <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
                Coming Soon
              </span>
            )}
          </div>
          {connection ? (
            <div className="flex items-center space-x-1 text-sm text-gray-500">
              <CheckCircleIcon className="h-4 w-4 text-green-500" />
              <span>Connected to {connection.calendarName}</span>
            </div>
          ) : (
            <p className="text-sm text-gray-500">Not connected</p>
          )}
        </div>
      </div>

      <div className="flex items-center space-x-3">
        {connection && !isComingSoon && (
          <div className="flex items-center space-x-2">
            <Switch
              checked={connection.enabled}
              onCheckedChange={onToggle}
              disabled={loading}
            />
            <span className="text-sm text-gray-500">
              {connection.enabled ? 'On' : 'Off'}
            </span>
          </div>
        )}

        {connection && !isComingSoon ? (
          <Button
            variant="ghost"
            size="sm"
            onClick={onDisconnect}
            disabled={loading}
          >
            <XMarkIcon className="h-4 w-4" />
            Disconnect
          </Button>
        ) : !isComingSoon ? (
          <Button
            variant="outline"
            size="sm"
            onClick={onConnect}
            disabled={loading}
          >
            <LinkIcon className="h-4 w-4" />
            Connect
          </Button>
        ) : (
          <Button variant="ghost" size="sm" disabled>
            <LinkIcon className="h-4 w-4" />
            Connect
          </Button>
        )}
      </div>
    </div>
  );
}