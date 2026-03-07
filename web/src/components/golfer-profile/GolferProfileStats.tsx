import { Card } from '../ui/Card';
import { Badge } from '../ui/Badge';

interface GolferProfileStatsProps {
  profile: {
    displayHandicap: string;
    handicapIndex: number | null;
    totalRounds: number;
    bestScore: number | null;
    averageScore: number | null;
    lastPlayedOn: string | null;
    homeCourse: string | null;
    preferredTee: string | null;
    handicapUpdatedAt: string | null;
  };
}

export function GolferProfileStats({ profile }: GolferProfileStatsProps) {
  const statCards = [
    {
      label: 'Handicap Index',
      value: profile.displayHandicap,
      subtitle: profile.handicapUpdatedAt
        ? `Updated ${new Date(profile.handicapUpdatedAt).toLocaleDateString()}`
        : 'Not yet calculated',
    },
    {
      label: 'Rounds Played',
      value: profile.totalRounds.toString(),
      subtitle: profile.lastPlayedOn
        ? `Last: ${new Date(profile.lastPlayedOn).toLocaleDateString()}`
        : 'No rounds recorded',
    },
    {
      label: 'Best Score',
      value: profile.bestScore?.toString() ?? '—',
      subtitle: '18-hole rounds',
    },
    {
      label: 'Average Score',
      value: profile.averageScore?.toFixed(1) ?? '—',
      subtitle: '18-hole rounds',
    },
  ];

  return (
    <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
      {statCards.map((stat) => (
        <Card key={stat.label}>
          <div className="p-4">
            <p className="text-sm font-medium text-gray-500">{stat.label}</p>
            <p className="mt-1 text-2xl font-bold text-gray-900">{stat.value}</p>
            <p className="mt-1 text-xs text-gray-400">{stat.subtitle}</p>
          </div>
        </Card>
      ))}
      {(profile.homeCourse || profile.preferredTee) && (
        <Card className="col-span-2 lg:col-span-4">
          <div className="flex gap-4 p-4">
            {profile.homeCourse && (
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-500">Home Course:</span>
                <Badge variant="default">{profile.homeCourse}</Badge>
              </div>
            )}
            {profile.preferredTee && (
              <div className="flex items-center gap-2">
                <span className="text-sm text-gray-500">Preferred Tee:</span>
                <Badge variant="default">{profile.preferredTee}</Badge>
              </div>
            )}
          </div>
        </Card>
      )}
    </div>
  );
}
