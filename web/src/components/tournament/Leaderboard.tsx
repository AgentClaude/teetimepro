import { useState, useCallback } from "react";
import { useQuery, gql } from "@apollo/client";
import { useChannel } from "../../hooks/useActionCable";
import { Card } from "../ui/Card";
import { Badge } from "../ui/Badge";
import { LoadingSpinner } from "../ui/LoadingSpinner";

const LEADERBOARD_QUERY = gql`
  query TournamentLeaderboard($tournamentId: ID!) {
    tournamentLeaderboard(tournamentId: $tournamentId) {
      tournamentId
      totalRounds
      currentRound
      entries {
        position
        tied
        entryId
        playerId
        playerName
        teamName
        handicapIndex
        totalStrokes
        totalToPar
        totalHolesPlayed
        thru
        rounds {
          roundNumber
          totalStrokes
          scoreToPar
          holesPlayed
          completed
        }
      }
    }
  }
`;

export interface LeaderboardEntry {
  position: number;
  tied: boolean;
  entryId: string;
  playerId: string;
  playerName: string;
  teamName: string | null;
  handicapIndex: number | null;
  totalStrokes: number;
  totalToPar: number;
  totalHolesPlayed: number;
  thru: string | null;
  rounds: LeaderboardRound[];
}

export interface LeaderboardRound {
  roundNumber: number;
  totalStrokes: number;
  scoreToPar: number;
  holesPlayed: number;
  completed: boolean;
}

interface LeaderboardData {
  tournamentId: string;
  totalRounds: number;
  currentRound: number | null;
  entries: LeaderboardEntry[];
}

interface CableMessage {
  type: string;
  tournament_id: number;
  leaderboard: LeaderboardEntry[];
  updated_at: string;
}

export interface LeaderboardProps {
  tournamentId: string;
  tournamentName?: string;
  realTime?: boolean;
}

function formatScoreToPar(score: number): string {
  if (score === 0) return "E";
  if (score > 0) return `+${score}`;
  return `${score}`;
}

function scoreColorClass(score: number): string {
  if (score < 0) return "text-red-600 font-semibold";
  if (score === 0) return "text-rough-700";
  return "text-rough-500";
}

function positionDisplay(position: number, tied: boolean): string {
  return tied ? `T${position}` : `${position}`;
}

export function Leaderboard({
  tournamentId,
  tournamentName,
  realTime = true,
}: LeaderboardProps) {
  const [liveEntries, setLiveEntries] = useState<LeaderboardEntry[] | null>(
    null
  );
  const [lastUpdate, setLastUpdate] = useState<string | null>(null);

  const { data, loading, error } = useQuery<{
    tournamentLeaderboard: LeaderboardData;
  }>(LEADERBOARD_QUERY, {
    variables: { tournamentId },
    pollInterval: realTime ? 30000 : 0, // fallback polling every 30s
  });

  const handleCableMessage = useCallback((message: CableMessage) => {
    if (message.type === "leaderboard_update") {
      setLiveEntries(message.leaderboard);
      setLastUpdate(message.updated_at);
    }
  }, []);

  const { connected } = useChannel<CableMessage>({
    channel: "LeaderboardChannel",
    params: { tournament_id: tournamentId },
    onReceived: handleCableMessage,
  });

  const entries =
    liveEntries ?? data?.tournamentLeaderboard?.entries ?? [];
  const totalRounds = data?.tournamentLeaderboard?.totalRounds ?? 0;
  const currentRound = data?.tournamentLeaderboard?.currentRound;

  if (loading && !data) {
    return (
      <Card>
        <div className="flex justify-center py-12">
          <LoadingSpinner />
        </div>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <div className="text-center py-8 text-red-500">
          Failed to load leaderboard. Please try again.
        </div>
      </Card>
    );
  }

  return (
    <Card>
      <div className="flex items-center justify-between mb-4">
        <div>
          {tournamentName && (
            <h2 className="text-xl font-bold text-rough-900">
              {tournamentName}
            </h2>
          )}
          <h3 className="text-lg font-semibold text-rough-700">Leaderboard</h3>
          {currentRound && (
            <p className="text-sm text-rough-500">
              Round {currentRound} of {totalRounds}
            </p>
          )}
        </div>
        <div className="flex items-center gap-2">
          {realTime && (
            <Badge variant={connected ? "success" : "warning"}>
              {connected ? "● Live" : "○ Connecting..."}
            </Badge>
          )}
          {lastUpdate && (
            <span className="text-xs text-rough-400">
              Updated{" "}
              {new Date(lastUpdate).toLocaleTimeString([], {
                hour: "2-digit",
                minute: "2-digit",
              })}
            </span>
          )}
        </div>
      </div>

      {entries.length === 0 ? (
        <div className="text-center py-8 text-rough-500">
          No scores recorded yet. The leaderboard will update as scores come in.
        </div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b-2 border-rough-200 text-rough-600">
                <th className="text-left py-2 px-3 w-12">Pos</th>
                <th className="text-left py-2 px-3">Player</th>
                <th className="text-center py-2 px-3 w-16">To Par</th>
                <th className="text-center py-2 px-3 w-14">Thru</th>
                {Array.from({ length: totalRounds }, (_, i) => (
                  <th
                    key={i}
                    className="text-center py-2 px-3 w-12 hidden sm:table-cell"
                  >
                    R{i + 1}
                  </th>
                ))}
                <th className="text-center py-2 px-3 w-14">Total</th>
              </tr>
            </thead>
            <tbody>
              {entries.map((entry, idx) => (
                <tr
                  key={entry.entryId}
                  className={`border-b border-rough-100 hover:bg-fairway-50 transition-colors ${
                    idx < 3 ? "bg-fairway-50/30" : ""
                  }`}
                >
                  <td className="py-2.5 px-3 font-medium text-rough-700">
                    {positionDisplay(entry.position, entry.tied)}
                  </td>
                  <td className="py-2.5 px-3">
                    <div className="font-medium text-rough-900">
                      {entry.playerName}
                    </div>
                    {entry.teamName && (
                      <div className="text-xs text-rough-500">
                        {entry.teamName}
                      </div>
                    )}
                  </td>
                  <td
                    className={`text-center py-2.5 px-3 ${scoreColorClass(
                      entry.totalToPar
                    )}`}
                  >
                    {entry.totalHolesPlayed > 0
                      ? formatScoreToPar(entry.totalToPar)
                      : "-"}
                  </td>
                  <td className="text-center py-2.5 px-3 text-rough-500">
                    {entry.thru ?? "-"}
                  </td>
                  {Array.from({ length: totalRounds }, (_, i) => {
                    const round = entry.rounds.find(
                      (r) => r.roundNumber === i + 1
                    );
                    return (
                      <td
                        key={i}
                        className="text-center py-2.5 px-3 text-rough-600 hidden sm:table-cell"
                      >
                        {round ? round.totalStrokes : "-"}
                      </td>
                    );
                  })}
                  <td className="text-center py-2.5 px-3 font-semibold text-rough-800">
                    {entry.totalStrokes || "-"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </Card>
  );
}
