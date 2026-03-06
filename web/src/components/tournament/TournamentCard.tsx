import { Badge, statusBadgeVariant } from "../ui/Badge";
import { Card } from "../ui/Card";
import {
  CalendarDaysIcon,
  MapPinIcon,
  UserGroupIcon,
  TrophyIcon,
  CurrencyDollarIcon,
} from "@heroicons/react/24/outline";

export interface TournamentCardProps {
  id: string;
  name: string;
  format: string;
  status: string;
  startDate: string;
  endDate: string;
  courseName: string;
  entriesCount: number;
  maxParticipants: number | null;
  entryFeeDisplay: string;
  holes: number;
  registrationAvailable: boolean;
  onClick?: (id: string) => void;
}

const FORMAT_LABELS: Record<string, string> = {
  STROKE: "Stroke Play",
  MATCH_PLAY: "Match Play",
  SCRAMBLE: "Scramble",
  BEST_BALL: "Best Ball",
};

const STATUS_LABELS: Record<string, string> = {
  DRAFT: "Draft",
  REGISTRATION_OPEN: "Registration Open",
  REGISTRATION_CLOSED: "Registration Closed",
  IN_PROGRESS: "In Progress",
  COMPLETED: "Completed",
  CANCELLED: "Cancelled",
};

function tournamentStatusVariant(status: string) {
  switch (status) {
    case "REGISTRATION_OPEN":
      return "success";
    case "IN_PROGRESS":
      return "info";
    case "COMPLETED":
      return "neutral";
    case "CANCELLED":
      return "danger";
    case "REGISTRATION_CLOSED":
      return "warning";
    default:
      return statusBadgeVariant("default");
  }
}

function formatDate(dateStr: string): string {
  return new Date(dateStr + "T00:00:00").toLocaleDateString("en-US", {
    weekday: "short",
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

export function TournamentCard({
  id,
  name,
  format,
  status,
  startDate,
  endDate,
  courseName,
  entriesCount,
  maxParticipants,
  entryFeeDisplay,
  holes,
  registrationAvailable,
  onClick,
}: TournamentCardProps) {
  const isMultiDay = startDate !== endDate;

  return (
    <Card
      className="cursor-pointer hover:shadow-md transition-shadow"
      onClick={() => onClick?.(id)}
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold text-rough-900 truncate">
            {name}
          </h3>
          <div className="flex items-center gap-2 mt-1">
            <Badge variant={tournamentStatusVariant(status)}>
              {STATUS_LABELS[status] ?? status}
            </Badge>
            <Badge variant="info">{FORMAT_LABELS[format] ?? format}</Badge>
            <Badge variant="neutral">{holes} holes</Badge>
          </div>
        </div>
        <TrophyIcon className="h-6 w-6 text-fairway-600 flex-shrink-0" />
      </div>

      <div className="space-y-2 text-sm text-rough-600">
        <div className="flex items-center gap-2">
          <CalendarDaysIcon className="h-4 w-4" />
          <span>
            {formatDate(startDate)}
            {isMultiDay && ` – ${formatDate(endDate)}`}
          </span>
        </div>

        <div className="flex items-center gap-2">
          <MapPinIcon className="h-4 w-4" />
          <span>{courseName}</span>
        </div>

        <div className="flex items-center gap-2">
          <UserGroupIcon className="h-4 w-4" />
          <span>
            {entriesCount}
            {maxParticipants ? ` / ${maxParticipants}` : ""} registered
          </span>
        </div>

        <div className="flex items-center gap-2">
          <CurrencyDollarIcon className="h-4 w-4" />
          <span>{entryFeeDisplay === "$0.00" ? "Free" : entryFeeDisplay}</span>
        </div>
      </div>

      {registrationAvailable && (
        <div className="mt-4 pt-3 border-t border-rough-100">
          <span className="text-sm font-medium text-fairway-600">
            Registration open — Sign up now →
          </span>
        </div>
      )}
    </Card>
  );
}
