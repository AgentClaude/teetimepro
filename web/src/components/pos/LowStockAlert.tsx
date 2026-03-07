import { useState } from 'react';
import type { InventoryLevel } from '../../types/pos';
import { CATEGORY_ICONS } from '../../types/pos';

interface LowStockAlertProps {
  lowStockItems: InventoryLevel[];
  onViewProduct?: (productId: string) => void;
  onDismiss?: () => void;
  className?: string;
}

export function LowStockAlert({ 
  lowStockItems, 
  onViewProduct, 
  onDismiss, 
  className = '' 
}: LowStockAlertProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  if (lowStockItems.length === 0) return null;

  const outOfStockCount = lowStockItems.filter(item => item.stockStatus === 'out_of_stock').length;
  const lowStockCount = lowStockItems.filter(item => item.stockStatus === 'low_stock').length;

  const displayItems = isExpanded ? lowStockItems : lowStockItems.slice(0, 3);

  return (
    <div className={`bg-yellow-50 border border-yellow-200 rounded-lg p-4 ${className}`}>
      <div className="flex items-start justify-between">
        <div className="flex items-center space-x-2">
          <div className="flex-shrink-0">
            <svg className="w-5 h-5 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.19-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z" clipRule="evenodd" />
            </svg>
          </div>
          <div>
            <h3 className="text-sm font-medium text-yellow-800">
              Inventory Alert
            </h3>
            <div className="text-sm text-yellow-700">
              {outOfStockCount > 0 && lowStockCount > 0 && (
                <span>{outOfStockCount} out of stock, {lowStockCount} low stock</span>
              )}
              {outOfStockCount > 0 && lowStockCount === 0 && (
                <span>{outOfStockCount} product{outOfStockCount > 1 ? 's' : ''} out of stock</span>
              )}
              {outOfStockCount === 0 && lowStockCount > 0 && (
                <span>{lowStockCount} product{lowStockCount > 1 ? 's' : ''} low on stock</span>
              )}
            </div>
          </div>
        </div>
        
        <div className="flex items-center space-x-2">
          {lowStockItems.length > 3 && (
            <button
              onClick={() => setIsExpanded(!isExpanded)}
              className="text-sm font-medium text-yellow-800 hover:text-yellow-900 underline"
            >
              {isExpanded ? 'Show Less' : `Show All (${lowStockItems.length})`}
            </button>
          )}
          {onDismiss && (
            <button
              onClick={onDismiss}
              className="text-yellow-400 hover:text-yellow-600"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          )}
        </div>
      </div>

      <div className="mt-3 space-y-2">
        {displayItems.map((item) => (
          <div 
            key={item.id} 
            className="flex items-center justify-between bg-white rounded px-3 py-2 border border-yellow-200"
          >
            <div className="flex items-center space-x-3">
              <span className="text-lg">
                {CATEGORY_ICONS[item.posProduct.category]}
              </span>
              <div>
                <div className="font-medium text-gray-900 text-sm">
                  {item.posProduct.name}
                </div>
                <div className="text-xs text-gray-600">
                  {item.course.name} • SKU: {item.posProduct.sku}
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <div className="text-right">
                <div className={`text-sm font-medium ${
                  item.stockStatus === 'out_of_stock' ? 'text-red-600' : 'text-yellow-600'
                }`}>
                  {item.currentStock} {item.currentStock === 1 ? 'unit' : 'units'}
                </div>
                <div className="text-xs text-gray-500">
                  Reorder at {item.reorderPoint}
                </div>
              </div>

              <div className={`px-2 py-1 rounded-full text-xs font-medium ${
                item.stockStatus === 'out_of_stock'
                  ? 'bg-red-100 text-red-800'
                  : 'bg-yellow-100 text-yellow-800'
              }`}>
                {item.stockStatus === 'out_of_stock' ? 'Out' : 'Low'}
              </div>

              {onViewProduct && (
                <button
                  onClick={() => onViewProduct(item.posProduct.id)}
                  className="text-xs text-blue-600 hover:text-blue-800 font-medium underline"
                >
                  View
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {!isExpanded && lowStockItems.length > 3 && (
        <div className="mt-2 text-center">
          <button
            onClick={() => setIsExpanded(true)}
            className="text-sm text-yellow-700 hover:text-yellow-800 font-medium"
          >
            View {lowStockItems.length - 3} more items...
          </button>
        </div>
      )}
    </div>
  );
}