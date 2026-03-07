import { useState, useCallback } from 'react';
import { useQuery, useMutation } from '@apollo/client';
import { Modal } from '../ui/Modal';
import { ProductGrid } from '../pos/ProductGrid';
import { TurnOrderCart } from './TurnOrderCart';
import { GET_POS_PRODUCTS } from '../../graphql/pos';
import { CREATE_TURN_ORDER } from '../../graphql/turnOrders';
import type { PosProduct } from '../../types/pos';
import type { TurnOrderCartItem } from '../../types/turnOrder';

interface TurnOrderModalProps {
  isOpen: boolean;
  onClose: () => void;
  bookingId: string;
  golferName: string;
  teeTime: string;
  onSuccess?: () => void;
}

export function TurnOrderModal({
  isOpen,
  onClose,
  bookingId,
  golferName,
  teeTime,
  onSuccess,
}: TurnOrderModalProps) {
  const [cart, setCart] = useState<TurnOrderCartItem[]>([]);
  const [deliveryHole, setDeliveryHole] = useState(10);
  const [deliveryNotes, setDeliveryNotes] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const { data, loading: productsLoading } = useQuery(GET_POS_PRODUCTS, {
    variables: { activeOnly: true, category: null },
    skip: !isOpen,
  });

  const [createTurnOrder, { loading: submitting }] = useMutation(CREATE_TURN_ORDER);

  const products: PosProduct[] = (data?.posProducts ?? []).filter(
    (p: PosProduct) => p.category === 'food' || p.category === 'beverage'
  );

  const addToCart = useCallback((product: PosProduct) => {
    setError(null);
    setCart((prev) => {
      const existing = prev.find((item) => item.product.id === product.id);
      if (existing) {
        return prev.map((item) =>
          item.product.id === product.id
            ? { ...item, quantity: item.quantity + 1 }
            : item
        );
      }
      return [...prev, { product, quantity: 1 }];
    });
  }, []);

  const updateQuantity = useCallback((productId: string, quantity: number) => {
    setCart((prev) =>
      prev.map((item) =>
        item.product.id === productId ? { ...item, quantity } : item
      )
    );
  }, []);

  const removeItem = useCallback((productId: string) => {
    setCart((prev) => prev.filter((item) => item.product.id !== productId));
  }, []);

  const handleSubmit = useCallback(async () => {
    if (cart.length === 0) return;
    setError(null);

    try {
      const items = cart.map((item) => ({
        productId: item.product.id,
        quantity: item.quantity,
      }));

      const { data: result } = await createTurnOrder({
        variables: {
          bookingId,
          items,
          deliveryHole,
          deliveryNotes: deliveryNotes.trim() || null,
        },
      });

      if (result?.createTurnOrder?.tab) {
        setSuccess(true);
        setCart([]);
        setDeliveryNotes('');
        setTimeout(() => {
          setSuccess(false);
          onClose();
          onSuccess?.();
        }, 2000);
      } else {
        const errors = result?.createTurnOrder?.errors ?? ['Failed to create order'];
        setError(errors.join(', '));
      }
    } catch {
      setError('Failed to create turn order');
    }
  }, [cart, bookingId, deliveryHole, deliveryNotes, createTurnOrder, onClose, onSuccess]);

  const handleClose = useCallback(() => {
    setCart([]);
    setDeliveryNotes('');
    setError(null);
    setSuccess(false);
    onClose();
  }, [onClose]);

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Order Food at the Turn" size="xl">
      <div className="space-y-4">
        {/* Booking info */}
        <div className="rounded-lg bg-green-50 p-3">
          <p className="text-sm font-medium text-green-800">
            🏌️ {golferName} · {teeTime}
          </p>
        </div>

        {success && (
          <div className="rounded-lg border border-green-200 bg-green-50 p-3 text-center text-sm font-medium text-green-700">
            ✅ Turn order placed! Food will be ready at hole {deliveryHole}.
          </div>
        )}

        {error && (
          <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-2 text-sm text-red-700">
            {error}
          </div>
        )}

        {!success && (
          <div className="flex gap-4">
            {/* Product selection */}
            <div className="flex-1 overflow-y-auto" style={{ maxHeight: '400px' }}>
              <h3 className="mb-2 text-sm font-medium text-gray-700">Menu</h3>
              <ProductGrid
                products={products}
                onSelect={addToCart}
                loading={productsLoading}
              />
            </div>

            {/* Cart & delivery options */}
            <div className="w-72 flex-shrink-0">
              <TurnOrderCart
                items={cart}
                onUpdateQuantity={updateQuantity}
                onRemoveItem={removeItem}
                deliveryHole={deliveryHole}
                onDeliveryHoleChange={setDeliveryHole}
                deliveryNotes={deliveryNotes}
                onDeliveryNotesChange={setDeliveryNotes}
                onSubmit={handleSubmit}
                loading={submitting}
              />
            </div>
          </div>
        )}
      </div>
    </Modal>
  );
}
