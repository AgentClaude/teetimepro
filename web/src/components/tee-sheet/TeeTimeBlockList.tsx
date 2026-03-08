import React from 'react';

interface TeeTimeBlock {
  id: string;
  blockType: string;
  reason: string;
  description?: string | null;
  startsAt: string;
  endsAt: string;
  active: boolean;
  currentlyActive: boolean;
  affectedTeeTimeCount: number;
  durationMinutes: number;
  course: {
    id: string;
    name: string;
  };
  createdBy: {
    firstName: string;
    lastName: string;
  };
  createdAt: string;
}

interface TeeTimeBlockListProps {
  blocks: TeeTimeBlock[];
  onUnblock: (blockId: string) => void;
  isUnblocking?: string | null;
}

const BLOCK_TYPE_CONFIG: Record<string, { icon: string; color: string; bgColor: string }> = {
  maintenance: { icon: '🔧', color: 'text-orange-700', bgColor: 'bg-orange-50 border-orange-200' },
  event: { icon: '🏆', color: 'text-purple-700', bgColor: 'bg-purple-50 border-purple-200' },
  weather: { icon: '⛈️', color: 'text-blue-700', bgColor: 'bg-blue-50 border-blue-200' },
  other: { icon: '🚫', color: 'text-gray-700', bgColor: 'bg-gray-50 border-gray-200' },
};

const formatDateTime = (iso: string): string => {
  const d = new Date(iso);
  return d.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });
};

const formatDuration = (minutes: number): string => {
  if (minutes < 60) return `${minutes}m`;
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return m > 0 ? `${h}h ${m}m` : `${h}h`;
};

export const TeeTimeBlockList: React.FC<TeeTimeBlockListProps> = ({
  blocks,
  onUnblock,
  isUnblocking = null,
}) => {
  if (blocks.length === 0) {
    return (
      <div className="rounded-xl border border-dashed border-gray-300 p-8 text-center">
        <div className="text-3xl">✅</div>
        <p className="mt-2 text-sm font-medium text-gray-600">No active blocks</p>
        <p className="text-xs text-gray-400">All tee times are available</p>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {blocks.map((block) => {
        const config = BLOCK_TYPE_CONFIG[block.blockType] || BLOCK_TYPE_CONFIG.other;

        return (
          <div
            key={block.id}
            className={`rounded-xl border p-4 transition-all ${config.bgColor} ${
              !block.active ? 'opacity-60' : ''
            }`}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-start gap-3">
                <span className="mt-0.5 text-xl">{config.icon}</span>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className={`text-sm font-semibold ${config.color}`}>{block.reason}</h3>
                    {block.currentlyActive && (
                      <span className="rounded-full bg-red-100 px-2 py-0.5 text-xs font-medium text-red-700">
                        Active Now
                      </span>
                    )}
                    {!block.active && (
                      <span className="rounded-full bg-gray-100 px-2 py-0.5 text-xs font-medium text-gray-500">
                        Removed
                      </span>
                    )}
                  </div>
                  {block.description && (
                    <p className="mt-0.5 text-xs text-gray-600">{block.description}</p>
                  )}
                  <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500">
                    <span>📅 {formatDateTime(block.startsAt)} — {formatDateTime(block.endsAt)}</span>
                    <span>⏱️ {formatDuration(block.durationMinutes)}</span>
                    <span>🕳️ {block.affectedTeeTimeCount} tee times</span>
                    <span>👤 {block.createdBy.firstName} {block.createdBy.lastName}</span>
                  </div>
                  <div className="mt-1 text-xs text-gray-400">
                    {block.course.name}
                  </div>
                </div>
              </div>

              {block.active && (
                <button
                  onClick={() => onUnblock(block.id)}
                  disabled={isUnblocking === block.id}
                  className="shrink-0 rounded-lg border border-green-300 bg-white px-3 py-1.5 text-xs font-medium text-green-700 hover:bg-green-50 disabled:opacity-50"
                >
                  {isUnblocking === block.id ? 'Unblocking...' : 'Unblock'}
                </button>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default TeeTimeBlockList;
