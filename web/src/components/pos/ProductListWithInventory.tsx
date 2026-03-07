import { useState } from 'react';
import type { PosProduct, PosProductCategory, InventoryLevel } from '../../types/pos';
import { CATEGORY_LABELS, CATEGORY_ICONS } from '../../types/pos';

interface ProductListWithInventoryProps {
  products: PosProduct[];
  onProductSelect?: (product: PosProduct) => void;
  showInventoryDetails?: boolean;
  loading?: boolean;
}

const CATEGORY_COLORS: Record<PosProductCategory, string> = {
  food: 'bg-orange-50 border-orange-200',
  beverage: 'bg-amber-50 border-amber-200',
  apparel: 'bg-blue-50 border-blue-200',
  equipment: 'bg-green-50 border-green-200',
  rental: 'bg-purple-50 border-purple-200',
  other: 'bg-gray-50 border-gray-200',
};

const ALL_CATEGORIES: PosProductCategory[] = [
  'food',
  'beverage',
  'apparel',
  'equipment',
  'rental',
  'other',
];

function StockStatusBadge({ inventoryLevel }: { inventoryLevel: InventoryLevel }) {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'in_stock':
        return 'bg-green-100 text-green-800 border-green-200';
      case 'low_stock':
        return 'bg-yellow-100 text-yellow-800 border-yellow-200';
      case 'out_of_stock':
        return 'bg-red-100 text-red-800 border-red-200';
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200';
    }
  };

  const getStatusText = (status: string) => {
    switch (status) {
      case 'in_stock':
        return 'In Stock';
      case 'low_stock':
        return 'Low Stock';
      case 'out_of_stock':
        return 'Out of Stock';
      default:
        return 'Unknown';
    }
  };

  return (
    <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border ${getStatusColor(inventoryLevel.stockStatus)}`}>
      {getStatusText(inventoryLevel.stockStatus)}
    </span>
  );
}

function ProductCard({ product, onSelect, showInventoryDetails }: { 
  product: PosProduct; 
  onSelect?: (product: PosProduct) => void;
  showInventoryDetails?: boolean;
}) {
  const handleClick = () => {
    onSelect?.(product);
  };

  const totalStock = product.inventoryLevels.reduce((sum, level) => sum + level.currentStock, 0);
  const hasLowStock = product.inventoryLevels.some(level => level.needsReorder);

  return (
    <div
      className={`p-4 border rounded-lg transition-colors cursor-pointer ${CATEGORY_COLORS[product.category]} ${!product.active ? 'opacity-50' : ''}`}
      onClick={handleClick}
    >
      <div className="flex justify-between items-start mb-2">
        <div className="flex items-center space-x-2">
          <span className="text-lg">{CATEGORY_ICONS[product.category]}</span>
          <h3 className="font-medium text-gray-900 truncate">{product.name}</h3>
        </div>
        {hasLowStock && (
          <span className="inline-flex items-center px-1.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
            ⚠️
          </span>
        )}
      </div>

      <div className="space-y-2">
        <div className="flex justify-between items-center text-sm">
          <span className="text-gray-500">SKU: {product.sku}</span>
          <span className="font-semibold text-gray-900">{product.formattedPrice}</span>
        </div>

        {product.trackInventory && (
          <div className="space-y-1">
            <div className="flex justify-between items-center text-sm">
              <span className="text-gray-500">Total Stock:</span>
              <span className={`font-medium ${totalStock <= 5 ? 'text-red-600' : 'text-gray-900'}`}>
                {totalStock}
              </span>
            </div>

            {showInventoryDetails && product.inventoryLevels.length > 0 && (
              <div className="mt-2 space-y-1">
                {product.inventoryLevels.slice(0, 2).map((level) => (
                  <div key={level.id} className="flex justify-between items-center text-xs text-gray-600">
                    <span>{level.course.name}:</span>
                    <div className="flex items-center space-x-2">
                      <span>{level.currentStock}</span>
                      <StockStatusBadge inventoryLevel={level} />
                    </div>
                  </div>
                ))}
                {product.inventoryLevels.length > 2 && (
                  <div className="text-xs text-gray-500">
                    +{product.inventoryLevels.length - 2} more locations...
                  </div>
                )}
              </div>
            )}
          </div>
        )}

        {!product.active && (
          <div className="text-xs text-red-600 font-medium">Inactive</div>
        )}
      </div>
    </div>
  );
}

export function ProductListWithInventory({ 
  products, 
  onProductSelect, 
  showInventoryDetails = true,
  loading = false 
}: ProductListWithInventoryProps) {
  const [activeCategory, setActiveCategory] = useState<PosProductCategory | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [showLowStockOnly, setShowLowStockOnly] = useState(false);

  const filteredProducts = products.filter(product => {
    // Category filter
    if (activeCategory !== 'all' && product.category !== activeCategory) {
      return false;
    }

    // Search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      if (!product.name.toLowerCase().includes(query) && 
          !product.sku.toLowerCase().includes(query)) {
        return false;
      }
    }

    // Low stock filter
    if (showLowStockOnly && !product.needsReorder) {
      return false;
    }

    return true;
  });

  if (loading) {
    return (
      <div className="animate-pulse space-y-4">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="h-32 bg-gray-200 rounded-lg" />
        ))}
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="space-y-4">
        {/* Search and Options */}
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1">
            <input
              type="text"
              placeholder="Search products by name or SKU..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <label className="flex items-center space-x-2">
            <input
              type="checkbox"
              checked={showLowStockOnly}
              onChange={(e) => setShowLowStockOnly(e.target.checked)}
              className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <span className="text-sm text-gray-700">Low stock only</span>
          </label>
        </div>

        {/* Category filters */}
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setActiveCategory('all')}
            className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
              activeCategory === 'all'
                ? 'bg-blue-100 text-blue-800 border border-blue-200'
                : 'bg-gray-100 text-gray-700 border border-gray-200 hover:bg-gray-200'
            }`}
          >
            All
          </button>
          {ALL_CATEGORIES.map((category) => (
            <button
              key={category}
              onClick={() => setActiveCategory(category)}
              className={`px-3 py-1 rounded-full text-sm font-medium transition-colors ${
                activeCategory === category
                  ? 'bg-blue-100 text-blue-800 border border-blue-200'
                  : 'bg-gray-100 text-gray-700 border border-gray-200 hover:bg-gray-200'
              }`}
            >
              {CATEGORY_ICONS[category]} {CATEGORY_LABELS[category]}
            </button>
          ))}
        </div>
      </div>

      {/* Results count */}
      <div className="text-sm text-gray-600">
        {filteredProducts.length} of {products.length} products
        {showLowStockOnly && ' (low stock only)'}
      </div>

      {/* Product grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
        {filteredProducts.map((product) => (
          <ProductCard
            key={product.id}
            product={product}
            onSelect={onProductSelect}
            showInventoryDetails={showInventoryDetails}
          />
        ))}
      </div>

      {filteredProducts.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          {searchQuery || showLowStockOnly ? 'No products match your filters' : 'No products found'}
        </div>
      )}
    </div>
  );
}