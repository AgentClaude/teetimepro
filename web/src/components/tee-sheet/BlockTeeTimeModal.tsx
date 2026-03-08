import React, { useState } from 'react';

interface BlockTeeTimeModalProps {
  courseId: string;
  courseName: string;
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: BlockTeeTimeFormData) => void;
  isLoading?: boolean;
  error?: string | null;
}

export interface BlockTeeTimeFormData {
  courseId: string;
  blockType: 'MAINTENANCE' | 'EVENT' | 'WEATHER' | 'OTHER';
  reason: string;
  description: string;
  startsAt: string;
  endsAt: string;
}

const BLOCK_TYPES = [
  { value: 'MAINTENANCE', label: 'Maintenance', icon: '🔧', description: 'Course work, aeration, mowing' },
  { value: 'EVENT', label: 'Event', icon: '🏆', description: 'Tournament, private event' },
  { value: 'WEATHER', label: 'Weather', icon: '⛈️', description: 'Weather-related closure' },
  { value: 'OTHER', label: 'Other', icon: '🚫', description: 'Other reason' },
] as const;

export const BlockTeeTimeModal: React.FC<BlockTeeTimeModalProps> = ({
  courseId,
  courseName,
  isOpen,
  onClose,
  onSubmit,
  isLoading = false,
  error = null,
}) => {
  const [blockType, setBlockType] = useState<BlockTeeTimeFormData['blockType']>('MAINTENANCE');
  const [reason, setReason] = useState('');
  const [description, setDescription] = useState('');
  const [startsAt, setStartsAt] = useState('');
  const [endsAt, setEndsAt] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({
      courseId,
      blockType,
      reason,
      description,
      startsAt,
      endsAt,
    });
  };

  const isValid = reason.trim() !== '' && startsAt !== '' && endsAt !== '' && endsAt > startsAt;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-2xl">
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-gray-900">Block Tee Times</h2>
          <button
            onClick={onClose}
            className="rounded-lg p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600"
            aria-label="Close"
          >
            <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <p className="mb-4 text-sm text-gray-500">
          Block tee times on <span className="font-medium text-gray-700">{courseName}</span>
        </p>

        {error && (
          <div className="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{error}</div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Block Type */}
          <div>
            <label className="mb-2 block text-sm font-medium text-gray-700">Block Type</label>
            <div className="grid grid-cols-2 gap-2">
              {BLOCK_TYPES.map((type) => (
                <button
                  key={type.value}
                  type="button"
                  onClick={() => setBlockType(type.value)}
                  className={`flex items-center gap-2 rounded-lg border-2 p-3 text-left transition-all ${
                    blockType === type.value
                      ? 'border-green-600 bg-green-50'
                      : 'border-gray-200 hover:border-gray-300'
                  }`}
                >
                  <span className="text-lg">{type.icon}</span>
                  <div>
                    <div className="text-sm font-medium text-gray-900">{type.label}</div>
                    <div className="text-xs text-gray-500">{type.description}</div>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Reason */}
          <div>
            <label htmlFor="reason" className="mb-1 block text-sm font-medium text-gray-700">
              Reason *
            </label>
            <input
              id="reason"
              type="text"
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="e.g., Greens aeration"
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500"
              maxLength={255}
              required
            />
          </div>

          {/* Description */}
          <div>
            <label htmlFor="description" className="mb-1 block text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Additional details..."
              rows={2}
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500"
              maxLength={2000}
            />
          </div>

          {/* Date/Time Range */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="startsAt" className="mb-1 block text-sm font-medium text-gray-700">
                Start *
              </label>
              <input
                id="startsAt"
                type="datetime-local"
                value={startsAt}
                onChange={(e) => setStartsAt(e.target.value)}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500"
                required
              />
            </div>
            <div>
              <label htmlFor="endsAt" className="mb-1 block text-sm font-medium text-gray-700">
                End *
              </label>
              <input
                id="endsAt"
                type="datetime-local"
                value={endsAt}
                onChange={(e) => setEndsAt(e.target.value)}
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500"
                required
              />
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
              disabled={isLoading}
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!isValid || isLoading}
              className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
            >
              {isLoading ? 'Blocking...' : 'Block Tee Times'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default BlockTeeTimeModal;
