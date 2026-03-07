import { useState, useCallback } from "react";
import { useQuery, gql } from "@apollo/client";
import { Leaderboard } from "./Leaderboard";
import { ScoreEntry } from "./ScoreEntry";
import { Card } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";

const LIVE_SCORING_QUERY = gql`
  query LiveScoringData($tournamentId: ID!) {
    tournament(id: $tournamentId) {
      id
      name
      status
      format
      holes
      course {
        id
        name
      }
      tournamentEntries {
        id
        user {
          id
          firstName
          lastName
        }
        teamName
        handicapIndex
        status
      }
      tournamentRounds {
        id
        roundNumber
        playDate
        status
      }
    }
    tournamentScorecard(tournamentEntryId: $firstEntryId) @skip(if: $skipScorecard) {
      holeNumber
      strokes
      par
      putts
      fairwayHit
      greenInRegulation
    }
  }
`;

interface TournamentRound {
  id: string;
  roundNumber: number;
  playDate: string;
  status: string;
}

interface TournamentEntry {
  id: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
  };
  teamName: string | null;
  handicapIndex: number | null;
  status: string;
}

// Standard course pars — in a real app, this would come from the Course model
function defaultHolePars(holes: number): Array<{ hole: number; par: number }> {
  const standardPars = [4, 4, 5, 3, 4, 4, 3, 5, 4, 4, 4, 3, 5, 4, 4, 3, 4, 5];
  return Array.from({ length: holes }, (_, i) => ({
    hole: i + 1,
    par: standardPars[i % 18],
  }));
}

export interface LiveScoringPageProps {
  tournamentId: string;
}

export function LiveScoringPage({ tournamentId }: LiveScoringPageProps) {
  const [activeTab, setActiveTab] = useState<"leaderboard" | "scoring">(
    "leaderboard"
  );
  const [selectedRoundId, setSelectedRoundId] = useState<string | null>(null);

  const { data, loading, error, refetch } = useQuery(LIVE_SCORING_QUERY, {
    variables: {
      tournamentId,
      firstEntryId: "0",
      skipScorecard: true,
    },
  });

  const handleScoreRecorded = useCallback(() => {
    refetch();
  }, [refetch]);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <div className="text-center py-8 text-red-500">
          Failed to load tournament data: {error.message}
        </div>
      </Card>
    );
  }

  const tournament = data?.tournament;
  if (!tournament) {
    return (
      <Card>
        <div className="text-center py-8 text-rough-500">
          Tournament not found.
        </div>
      </Card>
    );
  }

  const rounds: TournamentRound[] = tournament.tournamentRounds ?? [];
  const entries: TournamentEntry[] = tournament.tournamentEntries ?? [];
  const activeRound =
    rounds.find((r: TournamentRound) => r.id === selectedRoundId) ??
    rounds.find((r: TournamentRound) => r.status === "in_progress") ??
    rounds[rounds.length - 1];

  const holePars = defaultHolePars(tournament.holes);
  const playerEntries = entries
    .filter((e: TournamentEntry) => e.status !== "withdrawn")
    .map((e: TournamentEntry) => ({
      entryId: e.id,
      playerId: e.user.id,
      playerName: `${e.user.firstName} ${e.user.lastName}`,
    }));

  const isInProgress = tournament.status === "in_progress";

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-rough-900">
            {tournament.name}
          </h1>
          <p className="text-sm text-rough-500">
            {tournament.course.name} • {tournament.format} •{" "}
            {tournament.holes} holes
          </p>
        </div>
        <Badge
          variant={
            isInProgress
              ? "success"
              : tournament.status === "completed"
                ? "info"
                : "neutral"
          }
        >
          {tournament.status.replace("_", " ")}
        </Badge>
      </div>

      {/* Tab Switcher */}
      <div className="flex gap-1 bg-rough-100 p-1 rounded-lg w-fit">
        <button
          onClick={() => setActiveTab("leaderboard")}
          className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
            activeTab === "leaderboard"
              ? "bg-white text-rough-900 shadow-sm"
              : "text-rough-600 hover:text-rough-900"
          }`}
        >
          📊 Leaderboard
        </button>
        {isInProgress && (
          <button
            onClick={() => setActiveTab("scoring")}
            className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${
              activeTab === "scoring"
                ? "bg-white text-rough-900 shadow-sm"
                : "text-rough-600 hover:text-rough-900"
            }`}
          >
            ✏️ Score Entry
          </button>
        )}
      </div>

      {/* Round Selector */}
      {rounds.length > 1 && (
        <div className="flex gap-2">
          {rounds.map((round: TournamentRound) => (
            <button
              key={round.id}
              onClick={() => setSelectedRoundId(round.id)}
              className={`px-3 py-1.5 rounded-lg text-sm transition-all ${
                activeRound?.id === round.id
                  ? "bg-fairway-600 text-white"
                  : "bg-rough-100 text-rough-600 hover:bg-rough-200"
              }`}
            >
              Round {round.roundNumber}
              {round.status === "in_progress" && " •"}
            </button>
          ))}
        </div>
      )}

      {/* Content */}
      {activeTab === "leaderboard" ? (
        <Leaderboard
          tournamentId={tournamentId}
          tournamentName={tournament.name}
          realTime={isInProgress}
        />
      ) : (
        activeRound && (
          <ScoreEntry
            tournamentId={tournamentId}
            roundId={activeRound.id}
            roundNumber={activeRound.roundNumber}
            entries={playerEntries}
            holePars={holePars}
            onScoreRecorded={handleScoreRecorded}
          />
        )
      )}
    </div>
  );
}
