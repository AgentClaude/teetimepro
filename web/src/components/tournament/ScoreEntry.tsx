import { useState, useCallback } from "react";
import { useMutation, gql } from "@apollo/client";
import { Card } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";

const RECORD_SCORE_MUTATION = gql`
  mutation RecordTournamentScore(
    $tournamentId: ID!
    $tournamentEntryId: ID!
    $roundId: ID!
    $holeNumber: Int!
    $strokes: Int!
    $par: Int!
    $putts: Int
    $fairwayHit: Boolean
    $greenInRegulation: Boolean
  ) {
    recordTournamentScore(
      tournamentId: $tournamentId
      tournamentEntryId: $tournamentEntryId
      roundId: $roundId
      holeNumber: $holeNumber
      strokes: $strokes
      par: $par
      putts: $putts
      fairwayHit: $fairwayHit
      greenInRegulation: $greenInRegulation
    ) {
      score {
        id
        holeNumber
        strokes
        par
        scoreToPar
        scoreLabel
        putts
        fairwayHit
        greenInRegulation
      }
      errors
    }
  }
`;

interface HolePar {
  hole: number;
  par: number;
}

interface PlayerEntry {
  entryId: string;
  playerId: string;
  playerName: string;
}

interface ExistingScore {
  holeNumber: number;
  strokes: number;
  par: number;
  putts: number | null;
  fairwayHit: boolean | null;
  greenInRegulation: boolean | null;
}

export interface ScoreEntryProps {
  tournamentId: string;
  roundId: string;
  roundNumber: number;
  entries: PlayerEntry[];
  holePars: HolePar[];
  existingScores?: Record<string, ExistingScore[]>;
  onScoreRecorded?: () => void;
}

interface HoleScoreInput {
  strokes: number | null;
  putts: number | null;
  fairwayHit: boolean | null;
  greenInRegulation: boolean | null;
}

function scoreLabel(strokes: number, par: number): string {
  const diff = strokes - par;
  if (diff <= -3) return "🦅🦅";
  if (diff === -2) return "🦅";
  if (diff === -1) return "🐦";
  if (diff === 0) return "";
  if (diff === 1) return "⬜";
  if (diff === 2) return "⬜⬜";
  return "⬜⬜⬜";
}

function scoreBgClass(strokes: number | null, par: number): string {
  if (strokes === null) return "";
  const diff = strokes - par;
  if (diff <= -2) return "bg-yellow-100 text-yellow-800";
  if (diff === -1) return "bg-red-100 text-red-800";
  if (diff === 0) return "bg-rough-50";
  if (diff === 1) return "bg-blue-100 text-blue-800";
  return "bg-blue-200 text-blue-900";
}

export function ScoreEntry({
  tournamentId,
  roundId,
  roundNumber,
  entries,
  holePars,
  existingScores = {},
  onScoreRecorded,
}: ScoreEntryProps) {
  const [selectedEntry, setSelectedEntry] = useState<string>(
    entries[0]?.entryId ?? ""
  );
  const [currentHole, setCurrentHole] = useState(1);
  const [scores, setScores] = useState<Record<string, Record<number, HoleScoreInput>>>(() => {
    const initial: Record<string, Record<number, HoleScoreInput>> = {};
    entries.forEach((entry) => {
      initial[entry.entryId] = {};
      const existing = existingScores[entry.entryId] ?? [];
      existing.forEach((score) => {
        initial[entry.entryId][score.holeNumber] = {
          strokes: score.strokes,
          putts: score.putts,
          fairwayHit: score.fairwayHit,
          greenInRegulation: score.greenInRegulation,
        };
      });
    });
    return initial;
  });
  const [submitting, setSubmitting] = useState(false);
  const [lastSaved, setLastSaved] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const [recordScore] = useMutation(RECORD_SCORE_MUTATION);

  const currentPar = holePars.find((h) => h.hole === currentHole)?.par ?? 4;
  const currentScore = scores[selectedEntry]?.[currentHole];

  const handleStrokesChange = useCallback(
    (strokes: number) => {
      setScores((prev) => ({
        ...prev,
        [selectedEntry]: {
          ...prev[selectedEntry],
          [currentHole]: {
            ...prev[selectedEntry]?.[currentHole],
            strokes,
            putts: prev[selectedEntry]?.[currentHole]?.putts ?? null,
            fairwayHit: prev[selectedEntry]?.[currentHole]?.fairwayHit ?? null,
            greenInRegulation:
              prev[selectedEntry]?.[currentHole]?.greenInRegulation ?? null,
          },
        },
      }));
    },
    [selectedEntry, currentHole]
  );

  const handleStatsChange = useCallback(
    (field: "putts" | "fairwayHit" | "greenInRegulation", value: number | boolean | null) => {
      setScores((prev) => ({
        ...prev,
        [selectedEntry]: {
          ...prev[selectedEntry],
          [currentHole]: {
            ...prev[selectedEntry]?.[currentHole],
            strokes: prev[selectedEntry]?.[currentHole]?.strokes ?? null,
            putts: prev[selectedEntry]?.[currentHole]?.putts ?? null,
            fairwayHit: prev[selectedEntry]?.[currentHole]?.fairwayHit ?? null,
            greenInRegulation:
              prev[selectedEntry]?.[currentHole]?.greenInRegulation ?? null,
            [field]: value,
          },
        },
      }));
    },
    [selectedEntry, currentHole]
  );

  const handleSubmitHole = useCallback(async () => {
    const holeScore = scores[selectedEntry]?.[currentHole];
    if (!holeScore?.strokes) return;

    setSubmitting(true);
    setError(null);

    try {
      const { data } = await recordScore({
        variables: {
          tournamentId,
          tournamentEntryId: selectedEntry,
          roundId,
          holeNumber: currentHole,
          strokes: holeScore.strokes,
          par: currentPar,
          putts: holeScore.putts,
          fairwayHit: holeScore.fairwayHit,
          greenInRegulation: holeScore.greenInRegulation,
        },
      });

      if (data?.recordTournamentScore?.errors?.length > 0) {
        setError(data.recordTournamentScore.errors.join(", "));
      } else {
        setLastSaved(
          `Hole ${currentHole} saved for ${entries.find((e) => e.entryId === selectedEntry)?.playerName}`
        );
        onScoreRecorded?.();

        // Auto-advance to next hole
        if (currentHole < holePars.length) {
          setCurrentHole(currentHole + 1);
        }
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save score");
    } finally {
      setSubmitting(false);
    }
  }, [
    scores,
    selectedEntry,
    currentHole,
    currentPar,
    tournamentId,
    roundId,
    holePars.length,
    entries,
    recordScore,
    onScoreRecorded,
  ]);

  const selectedPlayer = entries.find((e) => e.entryId === selectedEntry);
  const playerScores = scores[selectedEntry] ?? {};
  const totalStrokes = Object.values(playerScores).reduce(
    (sum, s) => sum + (s.strokes ?? 0),
    0
  );
  const totalPar = Object.keys(playerScores).reduce((sum, hole) => {
    const h = holePars.find((hp) => hp.hole === Number(hole));
    return sum + (h?.par ?? 0);
  }, 0);
  const scoredHoles = Object.values(playerScores).filter(
    (s) => s.strokes !== null
  ).length;

  return (
    <Card>
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-lg font-semibold text-rough-900">
            Score Entry — Round {roundNumber}
          </h3>
          {lastSaved && (
            <p className="text-xs text-green-600 mt-1">✓ {lastSaved}</p>
          )}
        </div>
        <Badge variant="info">
          {scoredHoles}/{holePars.length} holes
        </Badge>
      </div>

      {/* Player Selector */}
      <div className="mb-4">
        <label className="block text-sm font-medium text-rough-700 mb-1">
          Player
        </label>
        <select
          value={selectedEntry}
          onChange={(e) => setSelectedEntry(e.target.value)}
          className="w-full rounded-lg border border-rough-300 px-3 py-2 text-sm focus:ring-2 focus:ring-fairway-500 focus:border-fairway-500"
        >
          {entries.map((entry) => (
            <option key={entry.entryId} value={entry.entryId}>
              {entry.playerName}
            </option>
          ))}
        </select>
      </div>

      {/* Hole Navigation Mini-Map */}
      <div className="mb-4">
        <div className="flex flex-wrap gap-1">
          {holePars.map((hp) => {
            const holeScore = playerScores[hp.hole];
            const isActive = hp.hole === currentHole;
            const hasScore = holeScore?.strokes != null;

            return (
              <button
                key={hp.hole}
                onClick={() => setCurrentHole(hp.hole)}
                className={`w-8 h-8 rounded-md text-xs font-medium transition-all ${
                  isActive
                    ? "ring-2 ring-fairway-500 bg-fairway-600 text-white"
                    : hasScore
                      ? `${scoreBgClass(holeScore?.strokes ?? null, hp.par)} border border-rough-200`
                      : "bg-rough-100 text-rough-500 border border-rough-200 hover:bg-rough-200"
                }`}
              >
                {hp.hole}
              </button>
            );
          })}
        </div>
      </div>

      {/* Current Hole Score Entry */}
      <div className="bg-rough-50 rounded-lg p-4 mb-4">
        <div className="flex items-center justify-between mb-3">
          <div>
            <span className="text-2xl font-bold text-rough-900">
              Hole {currentHole}
            </span>
            <span className="ml-2 text-sm text-rough-500">Par {currentPar}</span>
          </div>
          {currentScore?.strokes && (
            <span className="text-lg">
              {scoreLabel(currentScore.strokes, currentPar)}
            </span>
          )}
        </div>

        {/* Strokes Input */}
        <div className="mb-3">
          <label className="block text-sm font-medium text-rough-600 mb-2">
            Strokes
          </label>
          <div className="flex gap-1">
            {Array.from({ length: 8 }, (_, i) => i + 1).map((n) => (
              <button
                key={n}
                onClick={() => handleStrokesChange(n)}
                className={`w-10 h-10 rounded-lg text-sm font-semibold transition-all ${
                  currentScore?.strokes === n
                    ? `${scoreBgClass(n, currentPar)} ring-2 ring-offset-1 ring-fairway-500`
                    : "bg-white border border-rough-300 text-rough-700 hover:bg-rough-100"
                }`}
              >
                {n}
              </button>
            ))}
          </div>
        </div>

        {/* Putts */}
        <div className="mb-3">
          <label className="block text-sm font-medium text-rough-600 mb-2">
            Putts
          </label>
          <div className="flex gap-1">
            {[0, 1, 2, 3, 4].map((n) => (
              <button
                key={n}
                onClick={() => handleStatsChange("putts", n)}
                className={`w-10 h-10 rounded-lg text-sm font-medium transition-all ${
                  currentScore?.putts === n
                    ? "bg-fairway-100 text-fairway-800 ring-2 ring-fairway-500"
                    : "bg-white border border-rough-300 text-rough-700 hover:bg-rough-100"
                }`}
              >
                {n}
              </button>
            ))}
          </div>
        </div>

        {/* Stats Toggles */}
        <div className="flex gap-4">
          {currentPar > 3 && (
            <label className="flex items-center gap-2 text-sm">
              <input
                type="checkbox"
                checked={currentScore?.fairwayHit ?? false}
                onChange={(e) =>
                  handleStatsChange("fairwayHit", e.target.checked)
                }
                className="rounded border-rough-300 text-fairway-600 focus:ring-fairway-500"
              />
              <span className="text-rough-700">Fairway Hit</span>
            </label>
          )}
          <label className="flex items-center gap-2 text-sm">
            <input
              type="checkbox"
              checked={currentScore?.greenInRegulation ?? false}
              onChange={(e) =>
                handleStatsChange("greenInRegulation", e.target.checked)
              }
              className="rounded border-rough-300 text-fairway-600 focus:ring-fairway-500"
            />
            <span className="text-rough-700">GIR</span>
          </label>
        </div>
      </div>

      {/* Error Display */}
      {error && (
        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Actions */}
      <div className="flex items-center justify-between">
        <div className="flex gap-2">
          <button
            onClick={() => setCurrentHole(Math.max(1, currentHole - 1))}
            disabled={currentHole === 1}
            className="px-3 py-2 text-sm bg-rough-100 text-rough-700 rounded-lg hover:bg-rough-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            ← Prev
          </button>
          <button
            onClick={() =>
              setCurrentHole(Math.min(holePars.length, currentHole + 1))
            }
            disabled={currentHole === holePars.length}
            className="px-3 py-2 text-sm bg-rough-100 text-rough-700 rounded-lg hover:bg-rough-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Next →
          </button>
        </div>

        <button
          onClick={handleSubmitHole}
          disabled={!currentScore?.strokes || submitting}
          className="px-4 py-2 bg-fairway-600 text-white rounded-lg text-sm font-medium hover:bg-fairway-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
        >
          {submitting && <LoadingSpinner />}
          Save Hole {currentHole}
        </button>
      </div>

      {/* Summary Bar */}
      {scoredHoles > 0 && (
        <div className="mt-4 pt-4 border-t border-rough-200">
          <div className="flex justify-between text-sm">
            <span className="text-rough-600">
              {selectedPlayer?.playerName} — Through {scoredHoles}
            </span>
            <span
              className={`font-semibold ${
                totalStrokes - totalPar < 0
                  ? "text-red-600"
                  : totalStrokes - totalPar === 0
                    ? "text-rough-700"
                    : "text-blue-700"
              }`}
            >
              {totalStrokes} ({totalStrokes - totalPar === 0 ? "E" : totalStrokes - totalPar > 0 ? `+${totalStrokes - totalPar}` : totalStrokes - totalPar})
            </span>
          </div>
        </div>
      )}
    </Card>
  );
}
