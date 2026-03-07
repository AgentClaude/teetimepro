import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import {
  ArrowLeftIcon,
  CalendarDaysIcon,
  UserGroupIcon,
  CurrencyDollarIcon,
  TrophyIcon,
  MapPinIcon,
  PencilIcon,
  UserPlusIcon,
  UserMinusIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';
import { GET_TOURNAMENT } from '../graphql/queries';
import { 
  UPDATE_TOURNAMENT, 
  REGISTER_FOR_TOURNAMENT, 
  WITHDRAW_FROM_TOURNAMENT 
} from '../graphql/mutations';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';
import { Card } from '../components/ui/Card';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { Leaderboard } from '../components/tournament';

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
  const [showEditModal, setShowEditModal] = useState(false);

  const { data, loading, refetch } = useQuery(GET_TOURNAMENT, {
    variables: { id: id! },
    skip: !id,
  });

  const [updateTournament] = useMutation(UPDATE_TOURNAMENT, {
    onCompleted: () => {
      setShowEditModal(false);
      refetch();
    }
  });

  const [registerForTournament, { loading: registerLoading }] = useMutation(REGISTER_FOR_TOURNAMENT, {
    onCompleted: () => {
      setShowRegisterModal(false);
      refetch();
    }
  });

  const [withdrawFromTournament, { loading: withdrawLoading }] = useMutation(WITHDRAW_FROM_TOURNAMENT, {
    onCompleted: () => {
      refetch();
    }
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
  
  // Check if current user is registered
  const currentUserEntry = tournament.tournamentEntries.find(
    entry => entry.status === 'CONFIRMED' || entry.status === 'PENDING'
  );

  const confirmedEntries = tournament.tournamentEntries.filter(
    entry => entry.status === 'CONFIRMED'
  );
  
  const waitlistEntries = tournament.tournamentEntries.filter(
    entry => entry.status === 'WAITLISTED'
  );

  const handleRegister = async (formData: RegistrationFormData) => {
    try {
      await registerForTournament({
        variables: {
          tournamentId: tournament.id,
          handicapIndex: formData.handicapIndex ? parseFloat(formData.handicapIndex) : undefined,
          teamName: formData.teamName || undefined,
        }
      });
    } catch (error) {
      console.error('Error registering for tournament:', error);
    }
  };

  const handleWithdraw = async () => {
    if (confirm('Are you sure you want to withdraw from this tournament?')) {
      try {
        await withdrawFromTournament({
          variables: { tournamentId: tournament.id }
        });
      } catch (error) {
        console.error('Error withdrawing from tournament:', error);
      }
    }
  };

  const handleUpdateTournament = async (formData: EditTournamentFormData) => {
    try {
      await updateTournament({
        variables: {
          id: tournament.id,
          ...formData,
          maxParticipants: formData.maxParticipants ? parseInt(formData.maxParticipants) : undefined,
        }
      });
    } catch (error) {
      console.error('Error updating tournament:', error);
    }
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
          <h1 className="text-2xl font-bold text-gray-900 truncate">
            {tournament.name}
          </h1>
          <p className="text-sm text-gray-500">{tournament.course.name}</p>
        </div>
        <Badge variant={getStatusBadgeVariant(tournament.status)}>
          {getStatusDisplayText(tournament.status)}
        </Badge>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Tournament Info */}
          <Card>
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold">Tournament Details</h2>
                <Button 
                  variant="outline" 
                  size="sm"
                  onClick={() => setShowEditModal(true)}
                >
                  <PencilIcon className="h-4 w-4 mr-2" />
                  Edit
                </Button>
              </div>

              {tournament.description && (
                <p className="text-gray-600 mb-6">{tournament.description}</p>
              )}

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                <div className="space-y-4">
                  <div className="flex items-center">
                    <CalendarDaysIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {new Date(tournament.startDate).toLocaleDateString()} - {new Date(tournament.endDate).toLocaleDateString()}
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.days} day{tournament.days !== 1 ? 's' : ''}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center">
                    <TrophyIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {getFormatDisplayText(tournament.format)}
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.holes} holes, {tournament.teamSize} player{tournament.teamSize !== 1 ? 's' : ''} per team
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center">
                    <MapPinIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {tournament.course.name}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center">
                    <UserGroupIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {tournament.entriesCount} participant{tournament.entriesCount !== 1 ? 's' : ''}
                      </p>
                      <p className="text-sm text-gray-500">
                        {tournament.maxParticipants ? 
                          `Max: ${tournament.maxParticipants}` : 
                          'No participant limit'
                        }
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center">
                    <CurrencyDollarIcon className="h-5 w-5 text-gray-400 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {tournament.entryFeeDisplay}
                      </p>
                      <p className="text-sm text-gray-500">Entry fee</p>
                    </div>
                  </div>

                  {tournament.handicapEnabled && (
                    <div className="flex items-center">
                      <ClockIcon className="h-5 w-5 text-gray-400 mr-3" />
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          Handicap Required
                        </p>
                        {tournament.maxHandicap && (
                          <p className="text-sm text-gray-500">
                            Max handicap: {tournament.maxHandicap}
                          </p>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              </div>

              {/* Registration Timing */}
              {(tournament.registrationOpensAt || tournament.registrationClosesAt) && (
                <div className="mt-6 p-4 bg-gray-50 rounded-lg">
                  <h3 className="text-sm font-medium text-gray-900 mb-2">Registration Window</h3>
                  <div className="text-sm text-gray-600">
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

          {/* Leaderboard — shown when tournament is in progress or completed */}
          {(tournament.status === 'IN_PROGRESS' || tournament.status === 'COMPLETED') && (
            <Leaderboard
              tournamentId={tournament.id}
              tournamentName={tournament.name}
              realTime={tournament.status === 'IN_PROGRESS'}
            />
          )}

          {/* Participants */}
          <Card>
            <div className="p-6">
              <h2 className="text-lg font-semibold mb-4">Participants</h2>
              
              {confirmedEntries.length === 0 ? (
                <p className="text-gray-500 text-center py-8">No participants registered yet</p>
              ) : (
                <div className="space-y-4">
                  <div>
                    <h3 className="text-sm font-medium text-gray-900 mb-3">
                      Confirmed ({confirmedEntries.length})
                    </h3>
                    <div className="space-y-2">
                      {confirmedEntries.map((entry) => (
                        <div key={entry.id} className="flex items-center justify-between py-2 px-3 bg-gray-50 rounded-lg">
                          <div>
                            <p className="font-medium text-gray-900">{entry.user.fullName}</p>
                            <div className="flex items-center space-x-4 text-sm text-gray-500">
                              <span>{entry.user.email}</span>
                              {entry.teamName && <span>Team: {entry.teamName}</span>}
                              {entry.handicapIndex && <span>Handicap: {entry.handicapIndex}</span>}
                            </div>
                          </div>
                          <Badge variant="success">Confirmed</Badge>
                        </div>
                      ))}
                    </div>
                  </div>

                  {waitlistEntries.length > 0 && (
                    <div>
                      <h3 className="text-sm font-medium text-gray-900 mb-3">
                        Waitlist ({waitlistEntries.length})
                      </h3>
                      <div className="space-y-2">
                        {waitlistEntries.map((entry) => (
                          <div key={entry.id} className="flex items-center justify-between py-2 px-3 bg-yellow-50 rounded-lg">
                            <div>
                              <p className="font-medium text-gray-900">{entry.user.fullName}</p>
                              <div className="flex items-center space-x-4 text-sm text-gray-500">
                                <span>{entry.user.email}</span>
                                {entry.teamName && <span>Team: {entry.teamName}</span>}
                                {entry.handicapIndex && <span>Handicap: {entry.handicapIndex}</span>}
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
                  <div className="p-3 bg-green-50 rounded-lg">
                    <p className="text-sm text-green-800">
                      You are registered for this tournament
                    </p>
                    <p className="text-xs text-green-600 mt-1">
                      Status: {currentUserEntry.status}
                    </p>
                  </div>
                  <Button 
                    variant="outline" 
                    onClick={handleWithdraw}
                    disabled={withdrawLoading}
                    className="w-full"
                  >
                    <UserMinusIcon className="h-4 w-4 mr-2" />
                    {withdrawLoading ? 'Withdrawing...' : 'Withdraw'}
                  </Button>
                </div>
              ) : tournament.registrationAvailable ? (
                <Button 
                  onClick={() => setShowRegisterModal(true)}
                  className="w-full"
                >
                  <UserPlusIcon className="h-4 w-4 mr-2" />
                  Register
                </Button>
              ) : (
                <div className="p-3 bg-gray-50 rounded-lg">
                  <p className="text-sm text-gray-600">
                    Registration is not currently available
                  </p>
                </div>
              )}
            </div>
          </Card>

          {/* Tournament Stats */}
          <Card>
            <div className="p-6">
              <h3 className="text-lg font-semibold mb-4">Quick Stats</h3>
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Participants</span>
                  <span className="text-sm font-medium">
                    {tournament.entriesCount}
                    {tournament.maxParticipants && `/${tournament.maxParticipants}`}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Format</span>
                  <span className="text-sm font-medium">{getFormatDisplayText(tournament.format)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Entry Fee</span>
                  <span className="text-sm font-medium">{tournament.entryFeeDisplay}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-gray-600">Created By</span>
                  <span className="text-sm font-medium">{tournament.createdBy.fullName}</span>
                </div>
              </div>
            </div>
          </Card>
        </div>
      </div>

      {/* Registration Modal */}
      <RegistrationModal
        isOpen={showRegisterModal}
        onClose={() => setShowRegisterModal(false)}
        tournament={tournament}
        onSubmit={handleRegister}
        loading={registerLoading}
      />

      {/* Edit Tournament Modal */}
      <EditTournamentModal
        isOpen={showEditModal}
        onClose={() => setShowEditModal(false)}
        tournament={tournament}
        onSubmit={handleUpdateTournament}
      />
    </div>
  );
}

// Registration Modal Component
interface RegistrationFormData {
  handicapIndex: string;
  teamName: string;
}

interface RegistrationModalProps {
  isOpen: boolean;
  onClose: () => void;
  tournament: Tournament;
  onSubmit: (data: RegistrationFormData) => void;
  loading: boolean;
}

function RegistrationModal({ isOpen, onClose, tournament, onSubmit, loading }: RegistrationModalProps) {
  const [formData, setFormData] = useState({
    handicapIndex: '',
    teamName: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const needsTeamName = tournament.format === 'SCRAMBLE' || tournament.format === 'BEST_BALL';

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Register for Tournament">
      <div className="space-y-4">
        <div className="p-4 bg-blue-50 rounded-lg">
          <h3 className="font-medium text-blue-900">{tournament.name}</h3>
          <p className="text-sm text-blue-700 mt-1">
            Entry fee: {tournament.entryFeeDisplay}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {tournament.handicapEnabled && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Handicap Index
                {tournament.maxHandicap && (
                  <span className="text-gray-500"> (max {tournament.maxHandicap})</span>
                )}
              </label>
              <Input
                type="number"
                value={formData.handicapIndex}
                onChange={(e) => setFormData(prev => ({ ...prev, handicapIndex: e.target.value }))}
                placeholder="Enter your handicap index"
                step="0.1"
                max={tournament.maxHandicap}
              />
            </div>
          )}

          {needsTeamName && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Team Name {tournament.teamSize > 1 ? '(Optional)' : ''}
              </label>
              <Input
                value={formData.teamName}
                onChange={(e) => setFormData(prev => ({ ...prev, teamName: e.target.value }))}
                placeholder="Enter team name"
              />
            </div>
          )}

          <div className="flex justify-end space-x-3 pt-4">
            <Button type="button" variant="outline" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? 'Registering...' : 'Register'}
            </Button>
          </div>
        </form>
      </div>
    </Modal>
  );
}

// Edit Tournament Modal Component
interface EditTournamentFormData {
  name: string;
  description: string;
  maxParticipants: string;
  status: string;
}

interface EditTournamentModalProps {
  isOpen: boolean;
  onClose: () => void;
  tournament: Tournament;
  onSubmit: (data: EditTournamentFormData) => void;
}

function EditTournamentModal({ isOpen, onClose, tournament, onSubmit }: EditTournamentModalProps) {
  const [formData, setFormData] = useState({
    name: tournament.name,
    description: tournament.description || '',
    maxParticipants: tournament.maxParticipants?.toString() || '',
    status: tournament.status,
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({
      name: formData.name,
      description: formData.description || '',
      maxParticipants: formData.maxParticipants || '',
      status: formData.status,
    });
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Edit Tournament">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Tournament Name
          </label>
          <Input
            value={formData.name}
            onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Description
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
            rows={3}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Max Participants
          </label>
          <Input
            type="number"
            value={formData.maxParticipants}
            onChange={(e) => setFormData(prev => ({ ...prev, maxParticipants: e.target.value }))}
            placeholder="No limit"
            min="1"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Status
          </label>
          <select
            value={formData.status}
            onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value }))}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            <option value="DRAFT">Draft</option>
            <option value="REGISTRATION_OPEN">Registration Open</option>
            <option value="REGISTRATION_CLOSED">Registration Closed</option>
            <option value="IN_PROGRESS">In Progress</option>
            <option value="COMPLETED">Completed</option>
            <option value="CANCELLED">Cancelled</option>
          </select>
        </div>

        <div className="flex justify-end space-x-3 pt-4">
          <Button type="button" variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit">
            Update Tournament
          </Button>
        </div>
      </form>
    </Modal>
  );
}