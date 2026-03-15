import { useState, useCallback } from 'react';
import { useMutation } from '@apollo/client';
import { HoleScoreInput } from './HoleScoreInput';
import { Button } from '../ui/Button';
import { Card } from '../ui/Card';
import { UPDATE_HOLE_SCORE, FINALIZE_SCORECARD, ABANDON_SCORECARD } from '../../graphql/mutations';
import type { Scorecard, HoleScore } from '../../types/scorecard';

interface ScorecardGridProps {
  scorecard: Scorecard;
  onFinalized?: () => void;
  onAbandoned?: () => void;
}

function formatScoreToPar(score: number | null): string {
  if (score === null) return '-';
  if (score === 0) return 'E';
  return score > 0 ? `+${score}` : `${score}`;
}

export function ScorecardGrid({ scorecard, onFinalized, onAbandoned }: ScorecardGridProps) {
  const [activeHole, setActiveHole] = useState<number | null>(null);
  const [localScores, setLocalScores] = useState<HoleScore[]>(scorecard.holeScores);
  const [scorecardStats, setScorecardStats] = useState({
    totalStrokes: scorecard.totalStrokes,
    totalPutts: scorecard.totalPutts,
    frontNineStrokes: scorecard.frontNineStrokes,
    backNineStrokes: scorecard.backNineStrokes,
    scoreToPar: scorecard.scoreToPar,
    holesCompleted: scorecard.holesCompleted,
  });

  const [updateHoleScore, { loading: updating }] = useMutation(UPDATE_HOLE_SCORE);
  const [finalizeScorecard, { loading: finalizing }] = useMutation(FINALIZE_SCORECARD);
  const [abandonScorecard, { loading: abandoning }] = useMutation(ABANDON_SCORECARD);

  const isInProgress = scorecard.status === 'IN_PROGRESS';
  const frontNine = localScores.filter((h) => h.holeNumber <= 9);
  const backNine = localScores.filter((h) => h.holeNumber > 9);

  const handleScoreUpdate = useCallback(
    async (holeNumber: number, data: Partial<HoleScore>) => {
      // Optimistic update
      setLocalScores((prev) =>
        prev.map((h) => (h.holeNumber === holeNumber ? { ...h, ...data } : h))
      );

      try {
        const result = await updateHoleScore({
          variables: {
            scorecardId: scorecard.id,
            holeNumber,
            ...data,
          },
        });

        const response = result.data?.updateHoleScore;
        if (response?.errors?.length) {
          // Revert on error
          setLocalScores(scorecard.holeScores);
          console.error('Failed to update hole score:', response.errors);
          return;
        }

        if (response?.scorecard) {
          setScorecardStats({
            totalStrokes: response.scorecard.totalStrokes,
            totalPutts: response.scorecard.totalPutts,
            frontNineStrokes: response.scorecard.frontNineStrokes,
            backNineStrokes: response.scorecard.backNineStrokes,
            scoreToPar: response.scorecard.scoreToPar,
            holesCompleted: response.scorecard.holesCompleted,
          });
        }

        if (response?.holeScore) {
          setLocalScores((prev) =>
            prev.map((h) =>
              h.holeNumber === holeNumber ? { ...h, ...response.holeScore } : h
            )
          );
        }
      } catch (err) {
        setLocalScores(scorecard.holeScores);
        console.error('Error updating hole score:', err);
      }
    },
    [scorecard, updateHoleScore]
  );

  const handleFinalize = useCallback(async () => {
    if (!confirm('Finalize this scorecard? This cannot be undone.')) return;

    try {
      const result = await finalizeScorecard({
        variables: { scorecardId: scorecard.id },
      });

      if (result.data?.finalizeScorecard?.errors?.length) {
        alert(result.data.finalizeScorecard.errors.join(', '));
        return;
      }

      onFinalized?.();
    } catch (err) {
      console.error('Error finalizing scorecard:', err);
    }
  }, [scorecard.id, finalizeScorecard, onFinalized]);

  const handleAbandon = useCallback(async () => {
    if (!confirm('Abandon this scorecard? Your scores will be saved but not counted.')) return;

    try {
      const result = await abandonScorecard({
        variables: { scorecardId: scorecard.id },
      });

      if (result.data?.abandonScorecard?.errors?.length) {
        alert(result.data.abandonScorecard.errors.join(', '));
        return;
      }

      onAbandoned?.();
    } catch (err) {
      console.error('Error abandoning scorecard:', err);
    }
  }, [scorecard.id, abandonScorecard, onAbandoned]);

  return (
    <div className="space-y-4">
      {/* Header stats */}
      <Card className="p-4">
        <div className="flex items-center justify-between mb-2">
          <div>
            <h2 className="text-lg font-bold text-rough-900">{scorecard.course.name}</h2>
            <p className="text-sm text-rough-500">
              {new Date(scorecard.playedOn).toLocaleDateString()} · {scorecard.holesPlayed} holes
              {scorecard.teeColor && ` · ${scorecard.teeColor} tees`}
            </p>
          </div>
          <div className="text-right">
            <div className="text-3xl font-bold text-rough-900">
              {scorecardStats.totalStrokes ?? '-'}
            </div>
            <div className="text-sm font-medium text-rough-500">
              {formatScoreToPar(scorecardStats.scoreToPar)}
            </div>
          </div>
        </div>

        <div className="grid grid-cols-4 gap-2 text-center text-sm">
          <div>
            <div className="text-rough-500">Front</div>
            <div className="font-bold">{scorecardStats.frontNineStrokes ?? '-'}</div>
          </div>
          <div>
            <div className="text-rough-500">Back</div>
            <div className="font-bold">{scorecardStats.backNineStrokes ?? '-'}</div>
          </div>
          <div>
            <div className="text-rough-500">Putts</div>
            <div className="font-bold">{scorecardStats.totalPutts ?? '-'}</div>
          </div>
          <div>
            <div className="text-rough-500">Holes</div>
            <div className="font-bold">
              {scorecardStats.holesCompleted}/{scorecard.holesPlayed}
            </div>
          </div>
        </div>
      </Card>

      {/* Front Nine */}
      <Card className="p-4">
        <h3 className="text-sm font-semibold text-rough-700 mb-3">Front Nine</h3>
        <div className="grid grid-cols-9 gap-1">
          {frontNine.map((hole) => (
            <HoleScoreInput
              key={hole.id}
              holeScore={hole}
              isActive={activeHole === hole.holeNumber}
              onUpdate={handleScoreUpdate}
              onSelect={setActiveHole}
              disabled={!isInProgress}
            />
          ))}
        </div>
      </Card>

      {/* Back Nine */}
      {backNine.length > 0 && (
        <Card className="p-4">
          <h3 className="text-sm font-semibold text-rough-700 mb-3">Back Nine</h3>
          <div className="grid grid-cols-9 gap-1">
            {backNine.map((hole) => (
              <HoleScoreInput
                key={hole.id}
                holeScore={hole}
                isActive={activeHole === hole.holeNumber}
                onUpdate={handleScoreUpdate}
                onSelect={setActiveHole}
                disabled={!isInProgress}
              />
            ))}
          </div>
        </Card>
      )}

      {/* Actions */}
      {isInProgress && (
        <div className="flex gap-3">
          <Button
            variant="primary"
            onClick={handleFinalize}
            loading={finalizing}
            disabled={scorecardStats.holesCompleted === 0}
            className="flex-1"
          >
            Finalize Scorecard
          </Button>
          <Button
            variant="danger"
            onClick={handleAbandon}
            loading={abandoning}
          >
            Abandon
          </Button>
        </div>
      )}

      {updating && (
        <div className="text-center text-sm text-rough-400">Saving...</div>
      )}
    </div>
  );
}
