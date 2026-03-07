import type { CartItem } from '../../types/pos';

interface PosCartProps {
  items: CartItem[];
  onUpdateQuantity: (productId: string, quantity: number) => void;
  onRemoveItem: (productId: string) => void;
  onClear: () => void;
  onCheckout: () => void;
  golferName: string;
  onGolferNameChange: (name: string) => void;
  loading?: boolean;
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

export function PosCart({
  items,
  onUpdateQuantity,
  onRemoveItem,
  onClear,
  onCheckout,
  golferName,
  onGolferNameChange,
  loading = false,
}: PosCartProps) {
  const subtotal = items.reduce(
    (sum, item) => sum + item.product.priceCents * item.quantity,
    0
  );
  const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <div className="flex h-full flex-col rounded-lg border border-gray-200 bg-white shadow-sm">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-gray-200 px-4 py-3">
        <h3 className="text-lg font-semibold text-gray-900">
          Cart{' '}
          {itemCount > 0 && (
            <span className="ml-1 rounded-full bg-green-100 px-2 py-0.5 text-sm text-green-700">
              {itemCount}
            </span>
          )}
        </h3>
        {items.length > 0 && (
          <button
            onClick={onClear}
            className="text-sm text-red-600 hover:text-red-700"
            disabled={loading}
          >
            Clear
          </button>
        )}
      </div>

      {/* Golfer name input */}
      <div className="border-b border-gray-100 px-4 py-2">
        <input
          type="text"
          value={golferName}
          onChange={(e) => onGolferNameChange(e.target.value)}
          placeholder="Customer name..."
          className="w-full rounded border border-gray-200 px-3 py-1.5 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500/20"
        />
      </div>

      {/* Items list */}
      <div className="flex-1 overflow-y-auto px-4 py-2">
        {items.length === 0 ? (
          <p className="py-8 text-center text-sm text-gray-400">
            Scan a barcode or tap a product to add items
          </p>
        ) : (
          <ul className="space-y-2">
            {items.map((item) => (
              <li
                key={item.product.id}
                className="flex items-center gap-3 rounded-lg bg-gray-50 p-2"
              >
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-gray-900">
                    {item.product.name}
                  </p>
                  <p className="text-xs text-gray-500">
                    {item.product.formattedPrice} each
                  </p>
                </div>

                {/* Quantity controls */}
                <div className="flex items-center gap-1">
                  <button
                    onClick={() =>
                      item.quantity === 1
                        ? onRemoveItem(item.product.id)
                        : onUpdateQuantity(item.product.id, item.quantity - 1)
                    }
                    className="flex h-7 w-7 items-center justify-center rounded bg-gray-200 text-sm font-bold hover:bg-gray-300"
                    disabled={loading}
                  >
                    −
                  </button>
                  <span className="w-8 text-center text-sm font-semibold">
                    {item.quantity}
                  </span>
                  <button
                    onClick={() =>
                      onUpdateQuantity(item.product.id, item.quantity + 1)
                    }
                    className="flex h-7 w-7 items-center justify-center rounded bg-gray-200 text-sm font-bold hover:bg-gray-300"
                    disabled={loading}
                  >
                    +
                  </button>
                </div>

                {/* Line total */}
                <span className="w-16 text-right text-sm font-semibold text-gray-900">
                  {formatCents(item.product.priceCents * item.quantity)}
                </span>

                {/* Remove */}
                <button
                  onClick={() => onRemoveItem(item.product.id)}
                  className="text-gray-400 hover:text-red-500"
                  disabled={loading}
                >
                  <svg className="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Footer with total & checkout */}
      <div className="border-t border-gray-200 px-4 py-3">
        <div className="mb-3 flex items-center justify-between">
          <span className="text-lg font-semibold text-gray-900">Total</span>
          <span className="text-2xl font-bold text-green-700">{formatCents(subtotal)}</span>
        </div>
        <button
          onClick={onCheckout}
          disabled={items.length === 0 || !golferName.trim() || loading}
          className="w-full rounded-lg bg-green-600 px-4 py-3 text-lg font-semibold text-white transition-colors hover:bg-green-700 disabled:cursor-not-allowed disabled:bg-gray-300"
        >
          {loading ? 'Processing...' : 'Charge to Tab'}
        </button>
      </div>
    </div>
  );
}
