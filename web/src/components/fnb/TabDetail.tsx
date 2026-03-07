import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { Card } from '../ui/Card';
import { formatDistanceToNow } from 'date-fns';

export interface FnbTabItem {
  id: string;
  name: string;
  quantity: number;
  unitPriceCents: number;
  totalCents: number;
  category: 'food' | 'beverage' | 'other';
  notes?: string;
  addedBy: {
    fullName: string;
  };
  createdAt: string;
}

export interface FnbTabDetailData {
  id: string;
  golferName: string;
  status: 'open' | 'closed' | 'merged';
  totalCents: number;
  openedAt: string;
  closedAt?: string;
  itemCount: number;
  canBeModified: boolean;
  durationInMinutes?: number;
  course: {
    name: string;
  };
  user: {
    fullName: string;
  };
  fnbTabItems: FnbTabItem[];
}

interface TabDetailProps {
  tab: FnbTabDetailData;
  onAddItem?: () => void;
  onRemoveItem?: (itemId: string) => void;
  onCloseTab?: () => void;
  onBack?: () => void;
  loading?: boolean;
}

const formatCurrency = (cents: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(cents / 100);
};

const formatTimeAgo = (dateString: string): string => {
  return formatDistanceToNow(new Date(dateString), { addSuffix: true });
};

const CATEGORY_COLORS: Record<string, string> = {
  food: 'bg-orange-100 text-orange-800',
  beverage: 'bg-blue-100 text-blue-800',
  other: 'bg-gray-100 text-gray-800',
};

const STATUS_VARIANTS: Record<string, 'success' | 'warning' | 'danger' | 'default'> = {
  open: 'success',
  closed: 'default',
  merged: 'warning',
};

export const TabDetail: React.FC<TabDetailProps> = ({
  tab,
  onAddItem,
  onRemoveItem,
  onCloseTab,
  onBack,
  loading = false,
}) => {
  if (loading) {
    return (
      <div className="animate-pulse space-y-4">
        <div className="h-8 bg-gray-200 rounded w-1/3"></div>
        <div className="h-32 bg-gray-200 rounded"></div>
        <div className="space-y-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="h-16 bg-gray-200 rounded"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          {onBack && (
            <Button variant="outline" size="sm" onClick={onBack}>
              ← Back
            </Button>
          )}
          <div>
            <h1 className="text-2xl font-bold text-gray-900">
              {tab.golferName}'s Tab
            </h1>
            <div className="flex items-center gap-2 mt-1">
              <Badge variant={STATUS_VARIANTS[tab.status]}>
                {tab.status.toUpperCase()}
              </Badge>
              <span className="text-sm text-gray-500">
                {tab.course.name} • Server: {tab.user.fullName}
              </span>
            </div>
          </div>
        </div>
        
        <div className="text-right">
          <div className="text-3xl font-bold text-gray-900">
            {formatCurrency(tab.totalCents)}
          </div>
          <div className="text-sm text-gray-500">
            {tab.itemCount} items
          </div>
        </div>
      </div>

      {/* Tab Summary */}
      <Card className="p-4">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
          <div>
            <div className="text-gray-500">Opened</div>
            <div className="font-medium">{formatTimeAgo(tab.openedAt)}</div>
          </div>
          {tab.closedAt && (
            <div>
              <div className="text-gray-500">Closed</div>
              <div className="font-medium">{formatTimeAgo(tab.closedAt)}</div>
            </div>
          )}
          {tab.durationInMinutes && (
            <div>
              <div className="text-gray-500">Duration</div>
              <div className="font-medium">{tab.durationInMinutes} min</div>
            </div>
          )}
          <div>
            <div className="text-gray-500">Status</div>
            <div className="font-medium">
              {tab.canBeModified ? 'Modifiable' : 'Closed'}
            </div>
          </div>
        </div>
      </Card>

      {/* Items Section */}
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-semibold">Items ({tab.itemCount})</h2>
          {onAddItem && tab.canBeModified && (
            <Button onClick={onAddItem}>
              Add Item
            </Button>
          )}
        </div>

        {tab.fnbTabItems.length === 0 ? (
          <Card className="p-8 text-center text-gray-500">
            <p className="mb-4">No items on this tab yet</p>
            {onAddItem && tab.canBeModified && (
              <Button onClick={onAddItem}>
                Add First Item
              </Button>
            )}
          </Card>
        ) : (
          <div className="space-y-2">
            {tab.fnbTabItems.map((item) => (
              <Card key={item.id} className="p-4">
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-medium text-gray-900">{item.name}</h3>
                      <span className={`px-2 py-1 text-xs rounded-full ${CATEGORY_COLORS[item.category]}`}>
                        {item.category}
                      </span>
                    </div>
                    
                    <div className="text-sm text-gray-600">
                      <div>Qty: {item.quantity} × {formatCurrency(item.unitPriceCents)}</div>
                      <div>Added by {item.addedBy.fullName} {formatTimeAgo(item.createdAt)}</div>
                      {item.notes && (
                        <div className="italic">Note: {item.notes}</div>
                      )}
                    </div>
                  </div>

                  <div className="text-right">
                    <div className="font-semibold text-gray-900">
                      {formatCurrency(item.totalCents)}
                    </div>
                    
                    {onRemoveItem && tab.canBeModified && (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => onRemoveItem(item.id)}
                        className="mt-2 text-red-600 hover:text-red-700 hover:bg-red-50"
                      >
                        Remove
                      </Button>
                    )}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Actions */}
      {tab.canBeModified && tab.status === 'open' && (
        <Card className="p-4">
          <div className="flex justify-between items-center">
            <div>
              <h3 className="font-medium">Ready to close this tab?</h3>
              <p className="text-sm text-gray-500">
                Final total: {formatCurrency(tab.totalCents)}
              </p>
            </div>
            {onCloseTab && (
              <Button variant="primary" onClick={onCloseTab}>
                Close Tab
              </Button>
            )}
          </div>
        </Card>
      )}
    </div>
  );
};