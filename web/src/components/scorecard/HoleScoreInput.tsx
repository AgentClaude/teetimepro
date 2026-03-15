import { useState, useCallback } from 'react';
import { cn } from '../../lib/utils';
import type { HoleScore } from '../../types/scorecard';

interface HoleScoreInputProps {
  holeScore: HoleScore;
  isActive: boolean;
  onUpdate: (holeNumber: number, data: Partial<HoleScore>) => void;
  onSelect: (holeNumber: number) => void;
  disabled?: boolean;
}

function getScoreLabel(strokes: number | null, par: number): string {
  if (strokes === null) return '';
  const diff = strokes - par;
  if (diff <= -3) return 'Albatross';
  if (diff === -2) return 'Eagle';
  if (diff === -1) return 'Birdie';
  if (diff === 0) return 'Par';
  if (diff === 1) return 'Bogey';
  if (diff === 2) return 'Double';
  if (diff === 3) return 'Triple';
  return `+${diff}`;
}

function getScoreColor(strokes: number | null, par: number): string {
  if (strokes === null) return '';
  const diff = strokes - par;
  if (diff <= -2) return 'bg-yellow-100 text-yellow-800 ring-2 ring-yellow-400';
  if (diff === -1) return 'bg-red-100 text-red-700 ring-2 ring-red-400';
  if (diff === 0) return 'bg-white text-rough-900 ring-1 ring-rough-300';
  if (diff === 1) return 'bg-blue-100 text-blue-700 ring-1 ring-blue-300';
  return 'bg-blue-200 text-blue-900 ring-2 ring-blue-400';
}

export function HoleScoreInput({
  holeScore,
  isActive,
  onUpdate,
  onSelect,
  disabled = false,
}: HoleScoreInputProps) {
  const [showDetails, setShowDetails] = useState(false);

  const handleStrokeChange = useCallback(
    (delta: number) => {
      const current = holeScore.strokes ?? holeScore.par;
      const newStrokes = Math.max(1, Math.min(20, current + delta));
      onUpdate(holeScore.holeNumber, { strokes: newStrokes });
    },
    [holeScore, onUpdate]
  );

  const handleStrokeTap = useCallback(() => {
    if (holeScore.strokes === null) {
      onUpdate(holeScore.holeNumber, { strokes: holeScore.par });
    }
    onSelect(holeScore.holeNumber);
  }, [holeScore, onUpdate, onSelect]);

  return (
    <div
      className={cn(
        'flex flex-col items-center p-2 rounded-lg transition-all cursor-pointer',
        isActive ? 'bg-fairway-50 ring-2 ring-fairway-500' : 'hover:bg-rough-50',
        disabled && 'opacity-50 pointer-events-none'
      )}
      onClick={handleStrokeTap}
      role="button"
      tabIndex={0}
      aria-label={`Hole ${holeScore.holeNumber}, Par ${holeScore.par}`}
    >
      <span className="text-xs font-medium text-rough-500 mb-1">
        {holeScore.holeNumber}
      </span>
      <span className="text-xs text-rough-400 mb-1">Par {holeScore.par}</span>

      <div
        className={cn(
          'w-10 h-10 flex items-center justify-center rounded-full text-lg font-bold transition-all',
          holeScore.strokes !== null
            ? getScoreColor(holeScore.strokes, holeScore.par)
            : 'bg-rough-100 text-rough-400 ring-1 ring-rough-200'
        )}
      >
        {holeScore.strokes ?? '-'}
      </div>

      {holeScore.strokes !== null && (
        <span className="text-xs mt-1 text-rough-500">
          {getScoreLabel(holeScore.strokes, holeScore.par)}
        </span>
      )}

      {isActive && holeScore.strokes !== null && (
        <div className="flex gap-1 mt-2">
          <button
            className="w-7 h-7 rounded-full bg-rough-200 hover:bg-rough-300 text-rough-700 flex items-center justify-center text-sm font-bold"
            onClick={(e) => {
              e.stopPropagation();
              handleStrokeChange(-1);
            }}
            aria-label="Decrease strokes"
          >
            −
          </button>
          <button
            className="w-7 h-7 rounded-full bg-rough-200 hover:bg-rough-300 text-rough-700 flex items-center justify-center text-sm font-bold"
            onClick={(e) => {
              e.stopPropagation();
              handleStrokeChange(1);
            }}
            aria-label="Increase strokes"
          >
            +
          </button>
        </div>
      )}

      {isActive && (
        <button
          className="text-xs text-fairway-600 hover:text-fairway-800 mt-1"
          onClick={(e) => {
            e.stopPropagation();
            setShowDetails(!showDetails);
          }}
        >
          {showDetails ? 'Hide' : 'Details'}
        </button>
      )}

      {isActive && showDetails && (
        <div className="mt-2 space-y-1 w-full" onClick={(e) => e.stopPropagation()}>
          <label className="flex items-center gap-1 text-xs">
            <span className="text-rough-500">Putts:</span>
            <input
              type="number"
              min={0}
              max={10}
              value={holeScore.putts ?? ''}
              onChange={(e) =>
                onUpdate(holeScore.holeNumber, {
                  putts: e.target.value ? parseInt(e.target.value, 10) : null,
                })
              }
              className="w-12 px-1 py-0.5 border rounded text-center text-xs"
            />
          </label>
          <label className="flex items-center gap-1 text-xs">
            <input
              type="checkbox"
              checked={holeScore.fairwayHit ?? false}
              onChange={(e) =>
                onUpdate(holeScore.holeNumber, { fairwayHit: e.target.checked })
              }
              className="rounded"
            />
            <span className="text-rough-500">FIR</span>
          </label>
          <label className="flex items-center gap-1 text-xs">
            <input
              type="checkbox"
              checked={holeScore.greenInRegulation ?? false}
              onChange={(e) =>
                onUpdate(holeScore.holeNumber, {
                  greenInRegulation: e.target.checked,
                })
              }
              className="rounded"
            />
            <span className="text-rough-500">GIR</span>
          </label>
        </div>
      )}
    </div>
  );
}
