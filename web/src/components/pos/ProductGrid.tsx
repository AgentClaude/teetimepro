import { useState } from 'react';
import type { PosProduct, PosProductCategory } from '../../types/pos';
import { CATEGORY_LABELS, CATEGORY_ICONS } from '../../types/pos';

interface ProductGridProps {
  products: PosProduct[];
  onSelect: (product: PosProduct) => void;
  loading?: boolean;
}

const CATEGORY_COLORS: Record<PosProductCategory, string> = {
  food: 'bg-orange-50 border-orange-200 hover:bg-orange-100',
  beverage: 'bg-amber-50 border-amber-200 hover:bg-amber-100',
  apparel: 'bg-blue-50 border-blue-200 hover:bg-blue-100',
  equipment: 'bg-green-50 border-green-200 hover:bg-green-100',
  rental: 'bg-purple-50 border-purple-200 hover:bg-purple-100',
  other: 'bg-gray-50 border-gray-200 hover:bg-gray-100',
};

const ALL_CATEGORIES: PosProductCategory[] = [
  'food',
  'beverage',
  'apparel',
  'equipment',
  'rental',
  'other',
];

export function ProductGrid({ products, onSelect, loading = false }: ProductGridProps) {
  const [activeCategory, setActiveCategory] = useState<PosProductCategory | 'all'>('all');

  const filtered =
    activeCategory === 'all'
      ? products
      : products.filter((p) => p.category === activeCategory);

  const categoriesWithProducts = ALL_CATEGORIES.filter((cat) =>
    products.some((p) => p.category === cat)
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-green-500 border-t-transparent" />
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Category filter tabs */}
      <div className="flex flex-wrap gap-2">
        <button
          onClick={() => setActiveCategory('all')}
          className={`rounded-full px-3 py-1.5 text-sm font-medium transition-colors ${
            activeCategory === 'all'
              ? 'bg-green-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
        >
          All ({products.length})
        </button>
        {categoriesWithProducts.map((cat) => {
          const count = products.filter((p) => p.category === cat).length;
          return (
            <button
              key={cat}
              onClick={() => setActiveCategory(cat)}
              className={`rounded-full px-3 py-1.5 text-sm font-medium transition-colors ${
                activeCategory === cat
                  ? 'bg-green-600 text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              {CATEGORY_ICONS[cat]} {CATEGORY_LABELS[cat]} ({count})
            </button>
          );
        })}
      </div>

      {/* Product grid */}
      {filtered.length === 0 ? (
        <p className="py-8 text-center text-gray-500">No products found</p>
      ) : (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
          {filtered.map((product) => (
            <button
              key={product.id}
              onClick={() => onSelect(product)}
              disabled={!product.inStock}
              className={`flex flex-col items-center rounded-lg border-2 p-3 text-center transition-all ${
                product.inStock
                  ? `${CATEGORY_COLORS[product.category]} cursor-pointer active:scale-95`
                  : 'cursor-not-allowed border-gray-200 bg-gray-100 opacity-50'
              }`}
            >
              <span className="text-2xl">{CATEGORY_ICONS[product.category]}</span>
              <span className="mt-1 text-sm font-medium text-gray-900 line-clamp-2">
                {product.name}
              </span>
              <span className="mt-1 text-lg font-bold text-green-700">
                {product.formattedPrice}
              </span>
              {product.trackInventory && product.stockQuantity !== null && (
                <span
                  className={`mt-0.5 text-xs ${
                    product.stockQuantity <= 5 ? 'text-red-600' : 'text-gray-500'
                  }`}
                >
                  {product.stockQuantity} left
                </span>
              )}
              {!product.inStock && (
                <span className="mt-0.5 text-xs font-medium text-red-600">Out of stock</span>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
