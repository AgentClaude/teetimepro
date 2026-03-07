import type { TurnOrderCartItem } from '../../types/turnOrder';

interface TurnOrderCartProps {
  items: TurnOrderCartItem[];
  onUpdateQuantity: (productId: string, quantity: number) => void;
  onRemoveItem: (productId: string) => void;
  deliveryHole: number;
  onDeliveryHoleChange: (hole: number) => void;
  deliveryNotes: string;
  onDeliveryNotesChange: (notes: string) => void;
  onSubmit: () => void;
  loading?: boolean;
}

function formatCents(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

const DELIVERY_HOLES = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

export function TurnOrderCart({
  items,
  onUpdateQuantity,
  onRemoveItem,
  deliveryHole,
  onDeliveryHoleChange,
  deliveryNotes,
  onDeliveryNotesChange,
  onSubmit,
  loading = false,
}: TurnOrderCartProps) {
  const subtotal = items.reduce(
    (sum, item) => sum + item.product.priceCents * item.quantity,
    0
  );

  return (
    <div className="flex flex-col rounded-lg border border-gray-200 bg-white">
      <div className="border-b border-gray-200 px-3 py-2">
        <h3 className="text-sm font-semibold text-gray-900">Your Order</h3>
      </div>

      {/* Items */}
      <div className="max-h-48 overflow-y-auto px-3 py-2">
        {items.length === 0 ? (
          <p className="py-4 text-center text-xs text-gray-400">
            Tap items from the menu to add them
          </p>
        ) : (
          <ul className="space-y-1.5">
            {items.map((item) => (
              <li key={item.product.id} className="flex items-center gap-2 text-sm">
                <div className="min-w-0 flex-1">
                  <p className="truncate font-medium text-gray-900">{item.product.name}</p>
                </div>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() =>
                      item.quantity === 1
                        ? onRemoveItem(item.product.id)
                        : onUpdateQuantity(item.product.id, item.quantity - 1)
                    }
                    className="flex h-5 w-5 items-center justify-center rounded bg-gray-200 text-xs font-bold hover:bg-gray-300"
                    disabled={loading}
                  >
                    −
                  </button>
                  <span className="w-5 text-center text-xs font-semibold">{item.quantity}</span>
                  <button
                    onClick={() => onUpdateQuantity(item.product.id, item.quantity + 1)}
                    className="flex h-5 w-5 items-center justify-center rounded bg-gray-200 text-xs font-bold hover:bg-gray-300"
                    disabled={loading}
                  >
                    +
                  </button>
                </div>
                <span className="w-14 text-right text-xs font-semibold text-gray-700">
                  {formatCents(item.product.priceCents * item.quantity)}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Delivery options */}
      <div className="space-y-2 border-t border-gray-100 px-3 py-2">
        <div>
          <label className="mb-1 block text-xs font-medium text-gray-600">
            Deliver at hole
          </label>
          <select
            value={deliveryHole}
            onChange={(e) => onDeliveryHoleChange(Number(e.target.value))}
            className="w-full rounded border border-gray-200 px-2 py-1 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500/20"
          >
            {DELIVERY_HOLES.map((hole) => (
              <option key={hole} value={hole}>
                Hole {hole} {hole === 10 ? '(the turn)' : ''}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="mb-1 block text-xs font-medium text-gray-600">
            Special instructions
          </label>
          <textarea
            value={deliveryNotes}
            onChange={(e) => onDeliveryNotesChange(e.target.value)}
            placeholder="e.g., No onions, extra ketchup..."
            rows={2}
            className="w-full rounded border border-gray-200 px-2 py-1 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500/20"
          />
        </div>
      </div>

      {/* Total & submit */}
      <div className="border-t border-gray-200 px-3 py-2">
        <div className="mb-2 flex items-center justify-between">
          <span className="text-sm font-semibold text-gray-900">Total</span>
          <span className="text-lg font-bold text-green-700">{formatCents(subtotal)}</span>
        </div>
        <button
          onClick={onSubmit}
          disabled={items.length === 0 || loading}
          className="w-full rounded-lg bg-green-600 px-3 py-2 text-sm font-semibold text-white transition-colors hover:bg-green-700 disabled:cursor-not-allowed disabled:bg-gray-300"
        >
          {loading ? 'Placing order...' : '🍔 Place Turn Order'}
        </button>
      </div>
    </div>
  );
}
