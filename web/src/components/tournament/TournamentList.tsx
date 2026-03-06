import { useQuery } from "@apollo/client";
import { GET_TOURNAMENTS } from "../../graphql/queries";
import { TournamentCard } from "./TournamentCard";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import { useNavigate } from "react-router-dom";

interface Tournament {
  id: string;
  name: string;
  format: string;
  status: string;
  startDate: string;
  endDate: string;
  entriesCount: number;
  maxParticipants: number | null;
  entryFeeDisplay: string;
  holes: number;
  registrationAvailable: boolean;
  course: { id: string; name: string };
}

interface TournamentListProps {
  courseId?: string;
  status?: string;
  upcomingOnly?: boolean;
}

export function TournamentList({
  courseId,
  status,
  upcomingOnly = true,
}: TournamentListProps) {
  const navigate = useNavigate();
  const { data, loading, error } = useQuery<{
    tournaments: Tournament[];
  }>(GET_TOURNAMENTS, {
    variables: { courseId, status, upcomingOnly },
  });

  if (loading) return <LoadingSpinner />;
  if (error)
    return (
      <div className="text-red-600 p-4">
        Error loading tournaments: {error.message}
      </div>
    );

  const tournaments = data?.tournaments ?? [];

  if (tournaments.length === 0) {
    return (
      <div className="text-center py-12 text-rough-500">
        <p className="text-lg">No tournaments found</p>
        <p className="text-sm mt-1">
          Check back later or create a new tournament
        </p>
      </div>
    );
  }

  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {tournaments.map((tournament) => (
        <TournamentCard
          key={tournament.id}
          id={tournament.id}
          name={tournament.name}
          format={tournament.format}
          status={tournament.status}
          startDate={tournament.startDate}
          endDate={tournament.endDate}
          courseName={tournament.course.name}
          entriesCount={tournament.entriesCount}
          maxParticipants={tournament.maxParticipants}
          entryFeeDisplay={tournament.entryFeeDisplay}
          holes={tournament.holes}
          registrationAvailable={tournament.registrationAvailable}
          onClick={(id) => navigate(`/tournaments/${id}`)}
        />
      ))}
    </div>
  );
}
