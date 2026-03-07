import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import {
  ArrowLeftIcon,
  CalendarDaysIcon,
  UserGroupIcon,
  CurrencyDollarIcon,
  TrophyIcon,
  MapPinIcon,

  UserPlusIcon,
  ClockIcon,
  DocumentTextIcon,
  StarIcon,
} from '@heroicons/react/24/outline';
import { GET_TOURNAMENT } from '../graphql/queries';
import { WITHDRAW_FROM_TOURNAMENT } from '../graphql/mutations';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';
import { Card } from '../components/ui/Card';
import { TournamentRegistrationForm } from '../components/tournament/TournamentRegistrationForm';
import { WithdrawalConfirmationModal } from '../components/tournament/WithdrawalConfirmationModal';
import { formatDate } from '../lib/utils';

interface Tournament {
  id: string;
  name: string;
  description?: string;
  format: string;
  status: string;
  startDate: string;
  endDate: string;
  holes: number;
  teamSize: number;
  maxParticipants?: number;
  minParticipants: number;
  entriesCount: number;
  registrationAvailable: boolean;
  entryFeeCents: number;
  entryFeeDisplay: string;
  handicapEnabled: boolean;
  maxHandicap?: number;
  rules?: string;
  prizeStructure?: string;
  registrationOpensAt?: string;
  registrationClosesAt?: string;
  days: number;
  course: {
    id: string;
    name: string;
  };
  createdBy: {
    id: string;
    fullName: string;
  };
  tournamentEntries: Array<{
    id: string;
    status: string;
    teamName?: string;
    handicapIndex?: number;
    user: {
      id: string;
      fullName: string;
      email: string;
    };
  }>;
}

const getStatusBadgeVariant = (status: string) => {
  switch (status) {
    case 'REGISTRATION_OPEN':
      return 'success';
    case 'IN_PROGRESS':
      return 'warning';
    case 'COMPLETED':
      return 'default';
    case 'CANCELLED':
      return 'danger';
    default:
      return 'default';
  }
};

const getStatusDisplayText = (status: string) => {
  switch (status) {
    case 'DRAFT':
      return 'Draft';
    case 'REGISTRATION_OPEN':
      return 'Registration Open';
    case 'REGISTRATION_CLOSED':
      return 'Registration Closed';
    case 'IN_PROGRESS':
      return 'In Progress';
    case 'COMPLETED':
      return 'Completed';
    case 'CANCELLED':
      return 'Cancelled';
    default:
      return status;
  }
};

const getFormatDisplayText = (format: string) => {
  switch (format) {
    case 'STROKE':
      return 'Stroke Play';
    case 'MATCH_PLAY':
      return 'Match Play';
    case 'SCRAMBLE':
      return 'Scramble';
    case 'BEST_BALL':
      return 'Best Ball';
    case 'STABLEFORD':
      return 'Stableford';
    default:
      return format;
  }
};

export function TournamentDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [showRegisterModal, setShowRegisterModal] = useState(false);
  const [showWithdrawModal, setShowWithdrawModal] = useState(false);

  const { data, loading, refetch } = useQuery(GET_TOURNAMENT, {
    variables: { id: id! },
    skip: !id,
  });

  const [withdrawFromTournament, { loading: withdrawLoading }] = useMutation(WITHDRAW_FROM_TOURNAMENT, {
    onCompleted: () => {
      setShowWithdrawModal(false);
      refetch();
    },
    onError: (error) => {
      console.error('Error withdrawing from tournament:', error);
    },
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!data?.tournament) {
    return (
      <div className="text-center py-12">
        <TrophyIcon className="mx-auto h-12 w-12 text-gray-400" />
        <h3 className="mt-2 text-sm font-medium text-gray-900">Tournament not found</h3>
        <div className="mt-6">
          <Button onClick={() => navigate('/tournaments')}>
            Back to Tournaments
          </Button>
        </div>
      </div>
    );
  }

  const tournament: Tournament = data.tournament;
  
  // Check if current user is registered (This would typically use user context)
  const currentUserEntry = tournament.tournamentEntries.find(
    entry => ['REGISTERED', 'CONFIRMED', 'PENDING'].includes(entry.status)
  );

  const confirmedEntries = tournament.tournamentEntries.filter(
    entry => entry.status === 'CONFIRMED' || entry.status === 'REGISTERED'
  );
  
  const waitlistEntries = tournament.tournamentEntries.filter(
    entry => entry.status === 'WAITLISTED'
  );

  const handleWithdraw = async () => {
    try {
      await withdrawFromTournament({
        variables: { tournamentId: tournament.id }
      });
    } catch (error) {
      console.error('Error withdrawing from tournament:', error);
    }
  };

  const handleRegistrationSuccess = () => {
    refetch();
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button 
          variant="outline" 
          onClick={() => navigate('/tournaments')}
          className="flex-shrink-0"
        >
          <ArrowLeftIcon className="h-4 w-4 mr-2" />
          Back
        </Button>
        <div className="flex-1 min-w-0">
          <h1 className="text-3xl font-bold text-gray-900 truncate">
            {tournament.name}
          </h1>
          <p className="text-lg text-gray-500">{tournament.course.name}</p>
        </div>
        <Badge variant={getStatusBadgeVariant(tournament.status)} className="text-sm px-3 py-1">
          {getStatusDisplayText(tournament.status)}
        </Badge>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Tournament Overview */}
          <Card>
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-4">Tournament Details</h2>

              {tournament.description && (
                <div className="mb-6 p-4 bg-blue-50 rounded-lg">
                  <p className="text-gray-700">{tournament.description}</p>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div className="flex items-start">
                    <CalendarDaysIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {formatDate(tournament.startDate)}
                        {tournament.startDate !== tournament.endDate && (
                          <span> - {formatDate(tournament.endDate)}</span>
                        )}
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.days} day{tournament.days !== 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start">
                    <TrophyIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {getFormatDisplayText(tournament.format)}
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.holes} holes • {tournament.teamSize} player{tournament.teamSize !== 1 ? 's' : ''} per team
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start">
                    <MapPinIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {tournament.course.name}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex items-start">
                    <UserGroupIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {tournament.entriesCount} registered
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.maxParticipants ? 
                          `${tournament.maxParticipants - tournament.entriesCount} spots remaining` : 
                          'No participant limit'
                        }
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start">
                    <CurrencyDollarIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                    <div>
                      <p className="font-medium text-gray-900">
                        {tournament.entryFeeDisplay}
                      </p>
                      <p className="text-sm text-gray-500">Entry fee</p>
                    </div>
                  </div>

                  {tournament.handicapEnabled && (
                    <div className="flex items-start">
                      <ClockIcon className="h-5 w-5 text-gray-400 mr-3 mt-0.5" />
                      <div>
                        <p className="font-medium text-gray-900">
                          Handicap Required
                        </p>
                        {tournament.maxHandicap && (
                          <p className="text-sm text-gray-500">
                            Maximum handicap: {tournament.maxHandicap}
                          </p>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Registration Window */}
              {(tournament.registrationOpensAt || tournament.registrationClosesAt) && (
                <div className="mt-6 p-4 bg-gray-50 rounded-lg border">
                  <div className="flex items-center mb-2">
                    <ClockIcon className="h-4 w-4 text-gray-500 mr-2" />
                    <h3 className="font-medium text-gray-900">Registration Window</h3>
                  </div>
                  <div className="text-sm text-gray-600 space-y-1">
                    {tournament.registrationOpensAt && (
                      <p>Opens: {new Date(tournament.registrationOpensAt).toLocaleString()}</p>
                    )}
                    {tournament.registrationClosesAt && (
                      <p>Closes: {new Date(tournament.registrationClosesAt).toLocaleString()}</p>
                    )}
                  </div>
                </div>
              )}
            </div>
          </Card>

          {/* Rules and Prize Structure */}
          {(tournament.rules || tournament.prizeStructure) && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {tournament.rules && (
                <Card>
                  <div className="p-6">
                    <div className="flex items-center mb-4">
                      <DocumentTextIcon className="h-5 w-5 text-gray-400 mr-2" />
                      <h3 className="text-lg font-semibold">Tournament Rules</h3>
                    </div>
                    <div className="prose prose-sm max-w-none text-gray-700">
                      <div dangerouslySetInnerHTML={{ __html: tournament.rules.replace(/\n/g, '<br>') }} />
                    </div>
                  </div>
                </Card>
              )}

              {tournament.prizeStructure && (
                <Card>
                  <div className="p-6">
                    <div className="flex items-center mb-4">
                      <StarIcon className="h-5 w-5 text-gray-400 mr-2" />
                      <h3 className="text-lg font-semibold">Prize Structure</h3>
                    </div>
                    <div className="prose prose-sm max-w-none text-gray-700">
                      <div dangerouslySetInnerHTML={{ __html: tournament.prizeStructure.replace(/\n/g, '<br>') }} />
                    </div>
                  </div>
                </Card>
              )}
            </div>
          )}

          {/* Participants */}
          <Card>
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-4">
                Participants ({tournament.entriesCount})
              </h2>
              
              {confirmedEntries.length === 0 ? (
                <div className="text-center py-12">
                  <UserGroupIcon className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500 text-lg">No participants registered yet</p>
                  <p className="text-sm text-gray-400 mt-1">
                    Be the first to sign up for this tournament!
                  </p>
                </div>
              ) : (
                <div className="space-y-6">
                  <div>
                    <h3 className="text-lg font-medium text-gray-900 mb-4">
                      Registered ({confirmedEntries.length})
                    </h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      {confirmedEntries.map((entry, index) => (
                        <div key={entry.id} className="flex items-center justify-between p-4 bg-green-50 border border-green-200 rounded-lg">
                          <div className="flex items-center">
                            <div className="flex-shrink-0 w-8 h-8 bg-green-600 text-white rounded-full flex items-center justify-center text-sm font-medium">
                              {index + 1}
                            </div>
                            <div className="ml-3">
                              <p className="font-medium text-gray-900">{entry.user.fullName}</p>
                              <div className="flex items-center space-x-3 text-sm text-gray-500">
                                {entry.teamName && <span>Team: {entry.teamName}</span>}
                                {entry.handicapIndex !== null && entry.handicapIndex !== undefined && (
                                  <span>HCP: {entry.handicapIndex}</span>
                                )}
                              </div>
                            </div>
                          </div>
                          <Badge variant="success">Confirmed</Badge>
                        </div>
                      ))}
                    </div>
                  </div>

                  {waitlistEntries.length > 0 && (
                    <div>
                      <h3 className="text-lg font-medium text-gray-900 mb-4">
                        Waitlist ({waitlistEntries.length})
                      </h3>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        {waitlistEntries.map((entry, index) => (
                          <div key={entry.id} className="flex items-center justify-between p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                            <div className="flex items-center">
                              <div className="flex-shrink-0 w-8 h-8 bg-yellow-600 text-white rounded-full flex items-center justify-center text-sm font-medium">
                                {index + 1}
                              </div>
                              <div className="ml-3">
                                <p className="font-medium text-gray-900">{entry.user.fullName}</p>
                                <div className="flex items-center space-x-3 text-sm text-gray-500">
                                  {entry.teamName && <span>Team: {entry.teamName}</span>}
                                  {entry.handicapIndex !== null && entry.handicapIndex !== undefined && (
                                    <span>HCP: {entry.handicapIndex}</span>
                                  )}
                                </div>
                              </div>
                            </div>
                            <Badge variant="warning">Waitlisted</Badge>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Registration Actions */}
          <Card>
            <div className="p-6">
              <h3 className="text-lg font-semibold mb-4">Registration</h3>
              
              {currentUserEntry ? (
                <div className="space-y-4">
                  <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                    <div className="flex items-center mb-2">
                      <UserPlusIcon className="h-5 w-5 text-green-600 mr-2" />
                      <span className="font-medium text-green-800">Registered</span>
                    </div>
                    <p className="text-sm text-green-700">
                      You are registered for this tournament
                    </p>
                    <p className="text-xs text-green-600 mt-1">
                      Status: {currentUserEntry.status}
                    </p>
                  </div>
                  <Button 
                    variant="outline" 
                    onClick={() => setShowWithdrawModal(true)}
                    className="w-full"
                  >
                    Withdraw from Tournament
                  </Button>
                </div>
              ) : tournament.registrationAvailable ? (
                <div className="space-y-4">
                  <Button 
                    onClick={() => setShowRegisterModal(true)}
                    className="w-full"
                  >
                    <UserPlusIcon className="h-4 w-4 mr-2" />
                    Register Now
                  </Button>
                  {tournament.maxParticipants && tournament.entriesCount >= tournament.maxParticipants && (
                    <p className="text-sm text-amber-600 text-center">
                      Tournament is full. You will be added to the waitlist.
                    </p>
                  )}
                </div>
              ) : (
                <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
                  <p className="text-sm text-gray-600 text-center">
                    Registration is currently closed
                  </p>
                </div>
              )}
            </div>
          </Card>

          {/* Quick Stats */}
          <Card>
            <div className="p-6">
              <h3 className="text-lg font-semibold mb-4">Quick Facts</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Format</span>
                  <span className="text-sm font-medium">{getFormatDisplayText(tournament.format)}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Entry Fee</span>
                  <span className="text-sm font-medium">{tournament.entryFeeDisplay}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Holes</span>
                  <span className="text-sm font-medium">{tournament.holes}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Team Size</span>
                  <span className="text-sm font-medium">{tournament.teamSize}</span>
                </div>
                {tournament.maxParticipants && (
                  <div className="flex justify-between items-center">
                    <span className="text-sm text-gray-600">Max Players</span>
                    <span className="text-sm font-medium">{tournament.maxParticipants}</span>
                  </div>
                )}
                <div className="flex justify-between items-center">
                  <span className="text-sm text-gray-600">Created By</span>
                  <span className="text-sm font-medium">{tournament.createdBy.fullName}</span>
                </div>
              </div>
            </div>
          </Card>
        </div>
      </div>

      {/* Registration Modal */}
      <TournamentRegistrationForm
        tournament={tournament}
        isOpen={showRegisterModal}
        onClose={() => setShowRegisterModal(false)}
        onSuccess={handleRegistrationSuccess}
      />

      {/* Withdrawal Confirmation Modal */}
      <WithdrawalConfirmationModal
        isOpen={showWithdrawModal}
        onClose={() => setShowWithdrawModal(false)}
        onConfirm={handleWithdraw}
        loading={withdrawLoading}
        tournamentName={tournament.name}
        entryFeeDisplay={tournament.entryFeeDisplay}
        hasRefundPolicy={false} // This would be determined by tournament settings
      />
    </div>
  );
}