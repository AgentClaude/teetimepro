import { useState, useCallback } from 'react';
import { useQuery, useMutation } from '@apollo/client';
import { useCourse } from '../contexts/CourseContext';
import { BarcodeInput } from '../components/pos/BarcodeInput';
import { ProductGrid } from '../components/pos/ProductGrid';
import { PosCart } from '../components/pos/PosCart';
import { GET_POS_PRODUCTS, LOOKUP_POS_PRODUCT, POS_QUICK_SALE } from '../graphql/pos';
import type { PosProduct, CartItem } from '../types/pos';

export function PosPage() {
  const { selectedCourseId } = useCourse();
  const [cart, setCart] = useState<CartItem[]>([]);
  const [golferName, setGolferName] = useState('');
  const [scanError, setScanError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const { data, loading: productsLoading } = useQuery(GET_POS_PRODUCTS, {
    variables: { activeOnly: true },
    skip: !selectedCourseId,
  });

  const [lookupProduct] = useMutation(LOOKUP_POS_PRODUCT);
  const [quickSale, { loading: saleLoading }] = useMutation(POS_QUICK_SALE);

  const products: PosProduct[] = data?.posProducts ?? [];

  const addToCart = useCallback((product: PosProduct) => {
    setScanError(null);
    setSuccessMessage(null);

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

  const handleScan = useCallback(
    async (code: string) => {
      setScanError(null);
      setSuccessMessage(null);

      try {
        const { data: result } = await lookupProduct({ variables: { code } });

        if (result?.lookupPosProduct?.product) {
          addToCart(result.lookupPosProduct.product);
        } else {
          const errors = result?.lookupPosProduct?.errors ?? ['Product not found'];
          setScanError(errors.join(', '));
          setTimeout(() => setScanError(null), 3000);
        }
      } catch {
        setScanError('Failed to look up product');
        setTimeout(() => setScanError(null), 3000);
      }
    },
    [lookupProduct, addToCart]
  );

  const handleUpdateQuantity = useCallback((productId: string, quantity: number) => {
    setCart((prev) =>
      prev.map((item) =>
        item.product.id === productId ? { ...item, quantity } : item
      )
    );
  }, []);

  const handleRemoveItem = useCallback((productId: string) => {
    setCart((prev) => prev.filter((item) => item.product.id !== productId));
  }, []);

  const handleClear = useCallback(() => {
    setCart([]);
    setGolferName('');
    setScanError(null);
    setSuccessMessage(null);
  }, []);

  const handleCheckout = useCallback(async () => {
    if (cart.length === 0 || !golferName.trim()) return;

    try {
      const items = cart.map((item) => ({
        productId: item.product.id,
        quantity: item.quantity,
      }));

      const { data: result } = await quickSale({
        variables: { golferName: golferName.trim(), items },
      });

      if (result?.posQuickSale?.tab) {
        const total = (result.posQuickSale.tab.totalCents / 100).toFixed(2);
        setSuccessMessage(`✅ Tab opened for ${golferName} — $${total}`);
        setCart([]);
        setGolferName('');
        setTimeout(() => setSuccessMessage(null), 5000);
      } else {
        const errors = result?.posQuickSale?.errors ?? ['Sale failed'];
        setScanError(errors.join(', '));
      }
    } catch {
      setScanError('Failed to process sale');
    }
  }, [cart, golferName, quickSale]);

  return (
    <div className="flex h-[calc(100vh-4rem)] gap-6">
      {/* Left side: Scanner + Product Grid */}
      <div className="flex flex-1 flex-col space-y-4 overflow-hidden">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-gray-900">Point of Sale</h1>
        </div>

        {/* Barcode scanner input */}
        <BarcodeInput onScan={handleScan} disabled={saleLoading} />

        {/* Status messages */}
        {scanError && (
          <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-2 text-sm text-red-700">
            {scanError}
          </div>
        )}
        {successMessage && (
          <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-2 text-sm text-green-700">
            {successMessage}
          </div>
        )}

        {/* Product grid */}
        <div className="flex-1 overflow-y-auto">
          <ProductGrid
            products={products}
            onSelect={addToCart}
            loading={productsLoading}
          />
        </div>
      </div>

      {/* Right side: Cart */}
      <div className="w-96 flex-shrink-0">
        <PosCart
          items={cart}
          onUpdateQuantity={handleUpdateQuantity}
          onRemoveItem={handleRemoveItem}
          onClear={handleClear}
          onCheckout={handleCheckout}
          golferName={golferName}
          onGolferNameChange={setGolferName}
          loading={saleLoading}
        />
      </div>
    </div>
  );
}
