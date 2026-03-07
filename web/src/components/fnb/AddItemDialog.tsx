import { useState } from 'react';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';

interface AddItemDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: {
    name: string;
    quantity: number;
    unitPriceCents: number;
    category: 'food' | 'beverage' | 'other';
    notes?: string;
  }) => void;
  loading?: boolean;
}

export const AddItemDialog: React.FC<AddItemDialogProps> = ({
  isOpen,
  onClose,
  onSubmit,
  loading = false,
}) => {
  const [formData, setFormData] = useState({
    name: '',
    quantity: 1,
    unitPrice: '',
    category: 'food' as 'food' | 'beverage' | 'other',
    notes: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const newErrors: Record<string, string> = {};
    
    if (!formData.name.trim()) {
      newErrors.name = 'Item name is required';
    }
    
    if (formData.quantity <= 0) {
      newErrors.quantity = 'Quantity must be greater than 0';
    }
    
    const unitPrice = parseFloat(formData.unitPrice);
    if (isNaN(unitPrice) || unitPrice < 0) {
      newErrors.unitPrice = 'Valid unit price is required';
    }
    
    setErrors(newErrors);
    
    if (Object.keys(newErrors).length === 0) {
      onSubmit({
        name: formData.name.trim(),
        quantity: formData.quantity,
        unitPriceCents: Math.round(unitPrice * 100),
        category: formData.category,
        notes: formData.notes.trim() || undefined,
      });
      
      // Reset form
      setFormData({
        name: '',
        quantity: 1,
        unitPrice: '',
        category: 'food',
        notes: '',
      });
      setErrors({});
    }
  };

  const handleClose = () => {
    setFormData({
      name: '',
      quantity: 1,
      unitPrice: '',
      category: 'food',
      notes: '',
    });
    setErrors({});
    onClose();
  };

  const updateFormData = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Add Item to Tab" size="md">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Input
            id="name"
            label="Item Name"
            type="text"
            value={formData.name}
            onChange={(e) => updateFormData('name', e.target.value)}
            placeholder="e.g., Cheeseburger, Coca Cola"
            error={errors.name}
            disabled={loading}
            autoFocus
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <Input
              id="quantity"
              label="Quantity"
              type="number"
              min="1"
              value={formData.quantity}
              onChange={(e) => updateFormData('quantity', parseInt(e.target.value) || 0)}
              error={errors.quantity}
              disabled={loading}
            />
          </div>
          <div>
            <Input
              id="unitPrice"
              label="Unit Price ($)"
              type="number"
              step="0.01"
              min="0"
              value={formData.unitPrice}
              onChange={(e) => updateFormData('unitPrice', e.target.value)}
              placeholder="0.00"
              error={errors.unitPrice}
              disabled={loading}
            />
          </div>
        </div>

        <div>
          <label
            htmlFor="category"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Category
          </label>
          <select
            id="category"
            value={formData.category}
            onChange={(e) => updateFormData('category', e.target.value)}
            className={`
              w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm 
              focus:outline-none focus:ring-blue-500 focus:border-blue-500
              disabled:bg-gray-100 disabled:cursor-not-allowed
            `}
            disabled={loading}
          >
            <option value="food">Food</option>
            <option value="beverage">Beverage</option>
            <option value="other">Other</option>
          </select>
        </div>

        <div>
          <label
            htmlFor="notes"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Notes (optional)
          </label>
          <textarea
            id="notes"
            value={formData.notes}
            onChange={(e) => updateFormData('notes', e.target.value)}
            placeholder="Special instructions, modifications, etc."
            rows={3}
            className={`
              w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm 
              focus:outline-none focus:ring-blue-500 focus:border-blue-500
              disabled:bg-gray-100 disabled:cursor-not-allowed resize-none
            `}
            disabled={loading}
          />
        </div>

        {/* Price Preview */}
        {formData.quantity > 0 && formData.unitPrice && !isNaN(parseFloat(formData.unitPrice)) && (
          <div className="bg-gray-50 p-3 rounded-md">
            <div className="flex justify-between text-sm">
              <span>Total:</span>
              <span className="font-medium">
                ${(formData.quantity * parseFloat(formData.unitPrice)).toFixed(2)}
              </span>
            </div>
          </div>
        )}

        <div className="flex justify-end gap-3 pt-4">
          <Button
            type="button"
            variant="outline"
            onClick={handleClose}
            disabled={loading}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            disabled={loading}
          >
            {loading ? 'Adding...' : 'Add Item'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};
