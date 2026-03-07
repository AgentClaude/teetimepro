import { useState } from 'react';
import type { PosProduct, InventoryLevel } from '../../types/pos';

interface InventoryAdjustmentDialogProps {
  isOpen: boolean;
  onClose: () => void;
  product: PosProduct | null;
  selectedInventoryLevel?: InventoryLevel | null;
  onAdjustment: (data: {
    productId: string;
    courseId: string;
    quantity: number;
    notes: string;
    unitCostCents?: number;
  }) => Promise<void>;
  loading?: boolean;
}

export function InventoryAdjustmentDialog({
  isOpen,
  onClose,
  product,
  selectedInventoryLevel,
  onAdjustment,
  loading = false,
}: InventoryAdjustmentDialogProps) {
  const [selectedCourseId, setSelectedCourseId] = useState(
    selectedInventoryLevel?.course.id || product?.inventoryLevels[0]?.course.id || ''
  );
  const [adjustmentType, setAdjustmentType] = useState<'increase' | 'decrease'>('increase');
  const [quantity, setQuantity] = useState('');
  const [notes, setNotes] = useState('');
  const [unitCostCents, setUnitCostCents] = useState('');

  const selectedLevel = product?.inventoryLevels.find(level => level.course.id === selectedCourseId);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!product || !selectedCourseId || !quantity) return;

    const adjustmentQuantity = adjustmentType === 'decrease' ? -parseInt(quantity) : parseInt(quantity);
    const costCents = unitCostCents ? Math.round(parseFloat(unitCostCents) * 100) : undefined;

    try {
      await onAdjustment({
        productId: product.id,
        courseId: selectedCourseId,
        quantity: adjustmentQuantity,
        notes: notes || `${adjustmentType === 'increase' ? 'Increase' : 'Decrease'} stock adjustment`,
        unitCostCents: costCents,
      });
      
      // Reset form
      setQuantity('');
      setNotes('');
      setUnitCostCents('');
      onClose();
    } catch (error) {
      console.error('Adjustment failed:', error);
    }
  };

  const handleClose = () => {
    setQuantity('');
    setNotes('');
    setUnitCostCents('');
    onClose();
  };

  if (!isOpen || !product) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-lg w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h2 className="text-lg font-semibold text-gray-900">Adjust Inventory</h2>
              <p className="text-sm text-gray-600">{product.name} ({product.sku})</p>
            </div>
            <button
              onClick={handleClose}
              className="text-gray-400 hover:text-gray-600"
              disabled={loading}
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Course Selection */}
            {product.inventoryLevels.length > 1 && (
              <div>
                <label htmlFor="course" className="block text-sm font-medium text-gray-700 mb-1">
                  Location
                </label>
                <select
                  id="course"
                  value={selectedCourseId}
                  onChange={(e) => setSelectedCourseId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  required
                >
                  {product.inventoryLevels.map((level) => (
                    <option key={level.course.id} value={level.course.id}>
                      {level.course.name} (Current: {level.currentStock})
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Current Stock Display */}
            {selectedLevel && (
              <div className="bg-gray-50 p-3 rounded-md">
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-600">Current Stock:</span>
                  <span className="font-medium">{selectedLevel.currentStock}</span>
                </div>
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-600">Available:</span>
                  <span className="font-medium">{selectedLevel.availableStock}</span>
                </div>
                {selectedLevel.needsReorder && (
                  <div className="mt-1 text-xs text-yellow-600">
                    ⚠️ Below reorder point ({selectedLevel.reorderPoint})
                  </div>
                )}
              </div>
            )}

            {/* Adjustment Type */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Adjustment Type
              </label>
              <div className="flex space-x-4">
                <label className="flex items-center">
                  <input
                    type="radio"
                    name="adjustmentType"
                    value="increase"
                    checked={adjustmentType === 'increase'}
                    onChange={(e) => setAdjustmentType(e.target.value as 'increase' | 'decrease')}
                    className="text-blue-600 focus:ring-blue-500"
                  />
                  <span className="ml-2 text-sm text-gray-700">Increase Stock</span>
                </label>
                <label className="flex items-center">
                  <input
                    type="radio"
                    name="adjustmentType"
                    value="decrease"
                    checked={adjustmentType === 'decrease'}
                    onChange={(e) => setAdjustmentType(e.target.value as 'increase' | 'decrease')}
                    className="text-blue-600 focus:ring-blue-500"
                  />
                  <span className="ml-2 text-sm text-gray-700">Decrease Stock</span>
                </label>
              </div>
            </div>

            {/* Quantity */}
            <div>
              <label htmlFor="quantity" className="block text-sm font-medium text-gray-700 mb-1">
                Quantity
              </label>
              <input
                type="number"
                id="quantity"
                value={quantity}
                onChange={(e) => setQuantity(e.target.value)}
                min="1"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
                disabled={loading}
              />
            </div>

            {/* Unit Cost (optional) */}
            {adjustmentType === 'increase' && (
              <div>
                <label htmlFor="unitCost" className="block text-sm font-medium text-gray-700 mb-1">
                  Unit Cost (optional)
                </label>
                <div className="relative">
                  <span className="absolute left-3 top-2 text-gray-500">$</span>
                  <input
                    type="number"
                    id="unitCost"
                    value={unitCostCents}
                    onChange={(e) => setUnitCostCents(e.target.value)}
                    step="0.01"
                    min="0"
                    className="w-full pl-8 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="0.00"
                    disabled={loading}
                  />
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  Used for cost tracking and inventory valuation
                </p>
              </div>
            )}

            {/* Notes */}
            <div>
              <label htmlFor="notes" className="block text-sm font-medium text-gray-700 mb-1">
                Notes
              </label>
              <textarea
                id="notes"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Reason for adjustment (optional)"
                disabled={loading}
              />
            </div>

            {/* Buttons */}
            <div className="flex space-x-3 pt-4">
              <button
                type="button"
                onClick={handleClose}
                className="flex-1 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 border border-gray-300 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500"
                disabled={loading}
              >
                Cancel
              </button>
              <button
                type="submit"
                className={`flex-1 px-4 py-2 text-sm font-medium text-white rounded-md focus:outline-none focus:ring-2 ${
                  adjustmentType === 'increase'
                    ? 'bg-green-600 hover:bg-green-700 focus:ring-green-500'
                    : 'bg-red-600 hover:bg-red-700 focus:ring-red-500'
                } ${loading ? 'opacity-50 cursor-not-allowed' : ''}`}
                disabled={loading}
              >
                {loading ? 'Adjusting...' : `${adjustmentType === 'increase' ? 'Increase' : 'Decrease'} Stock`}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}