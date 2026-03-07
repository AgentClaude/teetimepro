import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { formatDistanceToNow } from 'date-fns';

export interface FnbTab {
  id: string;
  golferName: string;
  status: 'open' | 'closed' | 'merged';
  totalCents: number;
  openedAt: string;
  closedAt?: string;
  itemCount: number;
  canBeModified: boolean;
  course: {
    name: string;
  };
  user: {
    fullName: string;
  };
}

interface TabListProps {
  tabs: FnbTab[];
  onOpenTab?: () => void;
  onViewTab?: (id: string) => void;
  onCloseTab?: (id: string) => void;
  loading?: boolean;
}

const STATUS_VARIANTS: Record<string, 'success' | 'warning' | 'danger' | 'default'> = {
  open: 'success',
  closed: 'default',
  merged: 'warning',
};

const formatCurrency = (cents: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(cents / 100);
};

const formatTimeAgo = (dateString: string): string => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true });
};

export const TabList: React.FC<TabListProps> = ({
  tabs,
  onOpenTab,
  onViewTab,
  onCloseTab,
  loading = false,
}) => {
  if (loading) {
    return (
      <div className="animate-pulse space-y-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="h-20 bg-gray-200 rounded"></div>
        ))}
      </div>
    );
  }

  if (tabs.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        <p className="mb-4">No F&B tabs found</p>
        {onOpenTab && (
          <Button onClick={onOpenTab}>
            Open First Tab
          </Button>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-semibold">F&B Tabs</h2>
        {onOpenTab && (
          <Button onClick={onOpenTab}>
            Open New Tab
          </Button>
        )}
      </div>

      <div className="grid gap-4">
        {tabs.map((tab) => (
          <div
            key={tab.id}
            className="bg-white rounded-lg border shadow-sm p-4 hover:shadow-md transition-shadow"
          >
            <div className="flex justify-between items-start">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <h3 className="font-medium text-gray-900">{tab.golferName}</h3>
                  <Badge variant={STATUS_VARIANTS[tab.status]}>
                    {tab.status.toUpperCase()}
                  </Badge>
                </div>
                
                <div className="text-sm text-gray-600 space-y-1">
                  <div className="flex justify-between">
                    <span>Course:</span>
                    <span>{tab.course.name}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Server:</span>
                    <span>{tab.user.fullName}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Items:</span>
                    <span>{tab.itemCount}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Opened:</span>
                    <span>{formatTimeAgo(tab.openedAt)}</span>
                  </div>
                  {tab.closedAt && (
                    <div className="flex justify-between">
                      <span>Closed:</span>
                      <span>{formatTimeAgo(tab.closedAt)}</span>
                    </div>
                  )}
                </div>
              </div>

              <div className="text-right">
                <div className="text-lg font-semibold text-gray-900 mb-2">
                  {formatCurrency(tab.totalCents)}
                </div>
                
                <div className="flex gap-2">
                  {onViewTab && (
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => onViewTab(tab.id)}
                    >
                      View
                    </Button>
                  )}
                  
                  {onCloseTab && tab.canBeModified && tab.status === 'open' && (
                    <Button
                      variant="primary"
                      size="sm"
                      onClick={() => onCloseTab(tab.id)}
                    >
                      Close
                    </Button>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
