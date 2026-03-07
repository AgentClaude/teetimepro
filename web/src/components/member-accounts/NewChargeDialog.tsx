import { useState, useCallback } from 'react';
import { Card, CardHeader } from '../ui/Card';
import { Button } from '../ui/Button';
import { CHARGE_TYPE_LABELS } from './types';

interface NewChargeDialogProps {
  memberName: string;
  availableCreditCents: number;
  onSubmit: (data: NewChargeData) => void;
  onCancel: () => void;
  loading?: boolean;
}

export interface NewChargeData {
  amountCents: number;
  chargeType: string;
  description: string;
  notes?: string;
}

const formatCurrency = (cents: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(cents / 100);
};

export function NewChargeDialog({
  memberName,
  availableCreditCents,
  onSubmit,
  onCancel,
  loading = false,
}: NewChargeDialogProps) {
  const [amount, setAmount] = useState('');
  const [chargeType, setChargeType] = useState('fnb');
  const [description, setDescription] = useState('');
  const [notes, setNotes] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      setError(null);

      const amountCents = Math.round(parseFloat(amount) * 100);
      if (isNaN(amountCents) || amountCents <= 0) {
        setError('Please enter a valid amount');
        return;
      }

      if (amountCents > availableCreditCents) {
        setError(
          `Amount exceeds available credit of ${formatCurrency(availableCreditCents)}`
        );
        return;
      }

      if (!description.trim()) {
        setError('Please enter a description');
        return;
      }

      onSubmit({
        amountCents,
        chargeType,
        description: description.trim(),
        notes: notes.trim() || undefined,
      });
    },
    [amount, chargeType, description, notes, availableCreditCents, onSubmit]
  );

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-md">
        <CardHeader
          title="New Account Charge"
          subtitle={`Charging to ${memberName}'s account`}
        />

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Amount */}
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Amount
            </label>
            <div className="relative">
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-rough-500">
                $
              </span>
              <input
                type="number"
                step="0.01"
                min="0.01"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="0.00"
                className="w-full pl-8 pr-4 py-2 border border-rough-300 rounded-lg focus:ring-2 focus:ring-fairway-500 focus:border-fairway-500 outline-none"
                autoFocus
              />
            </div>
            <p className="text-xs text-rough-500 mt-1">
              Available credit: {formatCurrency(availableCreditCents)}
            </p>
          </div>

          {/* Charge Type */}
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Charge Type
            </label>
            <select
              value={chargeType}
              onChange={(e) => setChargeType(e.target.value)}
              className="w-full px-3 py-2 border border-rough-300 rounded-lg focus:ring-2 focus:ring-fairway-500 focus:border-fairway-500 outline-none"
            >
              {Object.entries(CHARGE_TYPE_LABELS).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Description
            </label>
            <input
              type="text"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="e.g., Pro shop purchase - golf balls"
              className="w-full px-3 py-2 border border-rough-300 rounded-lg focus:ring-2 focus:ring-fairway-500 focus:border-fairway-500 outline-none"
              maxLength={500}
            />
          </div>

          {/* Notes */}
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Notes (optional)
            </label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Additional details..."
              rows={2}
              className="w-full px-3 py-2 border border-rough-300 rounded-lg focus:ring-2 focus:ring-fairway-500 focus:border-fairway-500 outline-none resize-none"
              maxLength={1000}
            />
          </div>

          {/* Error */}
          {error && (
            <div className="text-sm text-red-600 bg-red-50 px-3 py-2 rounded-lg">
              {error}
            </div>
          )}

          {/* Actions */}
          <div className="flex gap-2 pt-2">
            <Button
              type="button"
              variant="outline"
              onClick={onCancel}
              className="flex-1"
              disabled={loading}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              variant="primary"
              className="flex-1"
              disabled={loading}
            >
              {loading ? 'Charging...' : 'Charge Account'}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
