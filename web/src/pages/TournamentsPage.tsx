import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import {
  PlusIcon,
  TrophyIcon,
  CalendarDaysIcon,
  UserGroupIcon,
  CurrencyDollarIcon,
} from '@heroicons/react/24/outline';
import { GET_TOURNAMENTS, GET_COURSES } from '../graphql/queries';
import { CREATE_TOURNAMENT } from '../graphql/mutations';
import { useCourse } from '../contexts/CourseContext';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { Input } from '../components/ui/Input';
import { Badge } from '../components/ui/Badge';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';
import { Card } from '../components/ui/Card';

interface Tournament {
  id: string;
  name: string;
  description?: string;
  format: string;
  status: string;
  startDate: string;
  endDate: string;
  maxParticipants?: number;
  entriesCount: number;
  entryFeeDisplay: string;
  registrationAvailable: boolean;
  course: {
    id: string;
    name: string;
  };
  createdBy: {
    id: string;
    fullName: string;
  };
}

interface Course {
  id: string;
  name: string;
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
      return 'error';
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

export function TournamentsPage() {
  const navigate = useNavigate();
  const { selectedCourseId } = useCourse();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [statusFilter, setStatusFilter] = useState<string>('');
  
  const { data: tournamentsData, loading: tournamentsLoading, refetch } = useQuery(GET_TOURNAMENTS, {
    variables: { 
      courseId: selectedCourseId || undefined,
      status: statusFilter || undefined,
    },
    skip: !selectedCourseId,
  });
  
  const { data: coursesData } = useQuery(GET_COURSES);
  
  const [createTournament, { loading: createLoading }] = useMutation(CREATE_TOURNAMENT, {
    onCompleted: (data) => {
      if (data.createTournament.tournament) {
        setShowCreateModal(false);
        refetch();
        navigate(`/tournaments/${data.createTournament.tournament.id}`);
      }
    }
  });

  const tournaments: Tournament[] = tournamentsData?.tournaments || [];
  const courses: Course[] = coursesData?.courses || [];

  const handleCreateTournament = async (formData: any) => {
    try {
      await createTournament({
        variables: {
          courseId: formData.courseId,
          name: formData.name,
          description: formData.description,
          format: formData.format,
          startDate: formData.startDate,
          endDate: formData.endDate,
          maxParticipants: formData.maxParticipants ? parseInt(formData.maxParticipants) : undefined,
          minParticipants: formData.minParticipants ? parseInt(formData.minParticipants) : undefined,
          entryFeeCents: formData.entryFee ? parseInt(formData.entryFee) * 100 : 0,
          holes: 18,
          teamSize: formData.format === 'SCRAMBLE' || formData.format === 'BEST_BALL' ? 4 : 1,
          handicapEnabled: formData.handicapEnabled === 'true',
        }
      });
    } catch (error) {
      console.error('Error creating tournament:', error);
    }
  };

  const filteredTournaments = tournaments.filter(tournament => {
    if (!statusFilter) return true;
    return tournament.status === statusFilter;
  });

  if (tournamentsLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tournaments</h1>
          <p className="text-sm text-gray-500">Manage tournament events and registrations</p>
        </div>
        <Button 
          onClick={() => setShowCreateModal(true)}
          className="sm:w-auto w-full"
        >
          <PlusIcon className="h-4 w-4 mr-2" />
          Create Tournament
        </Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap gap-4">
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-md border-gray-300 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
        >
          <option value="">All Statuses</option>
          <option value="DRAFT">Draft</option>
          <option value="REGISTRATION_OPEN">Registration Open</option>
          <option value="REGISTRATION_CLOSED">Registration Closed</option>
          <option value="IN_PROGRESS">In Progress</option>
          <option value="COMPLETED">Completed</option>
          <option value="CANCELLED">Cancelled</option>
        </select>
      </div>

      {/* Tournament Grid */}
      {filteredTournaments.length === 0 ? (
        <Card className="text-center py-12">
          <TrophyIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No tournaments</h3>
          <p className="mt-1 text-sm text-gray-500">
            Get started by creating a new tournament.
          </p>
          <div className="mt-6">
            <Button onClick={() => setShowCreateModal(true)}>
              <PlusIcon className="h-4 w-4 mr-2" />
              Create Tournament
            </Button>
          </div>
        </Card>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {filteredTournaments.map((tournament) => (
            <Card 
              key={tournament.id} 
              className="cursor-pointer hover:shadow-lg transition-shadow"
              onClick={() => navigate(`/tournaments/${tournament.id}`)}
            >
              <div className="p-6">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-semibold text-gray-900 truncate">
                      {tournament.name}
                    </h3>
                    <p className="text-sm text-gray-500 mt-1">
                      {tournament.course.name}
                    </p>
                  </div>
                  <Badge variant={getStatusBadgeVariant(tournament.status)}>
                    {getStatusDisplayText(tournament.status)}
                  </Badge>
                </div>

                {tournament.description && (
                  <p className="text-sm text-gray-600 mt-3 line-clamp-2">
                    {tournament.description}
                  </p>
                )}

                <div className="flex items-center space-x-4 mt-4 text-sm text-gray-500">
                  <div className="flex items-center">
                    <CalendarDaysIcon className="h-4 w-4 mr-1" />
                    {new Date(tournament.startDate).toLocaleDateString()}
                  </div>
                  <div className="flex items-center">
                    <UserGroupIcon className="h-4 w-4 mr-1" />
                    {tournament.entriesCount}
                    {tournament.maxParticipants && `/${tournament.maxParticipants}`}
                  </div>
                  <div className="flex items-center">
                    <CurrencyDollarIcon className="h-4 w-4 mr-1" />
                    {tournament.entryFeeDisplay}
                  </div>
                </div>

                <div className="flex items-center justify-between mt-4">
                  <span className="text-sm text-gray-600">
                    {getFormatDisplayText(tournament.format)}
                  </span>
                  {tournament.registrationAvailable && (
                    <Badge variant="success">Registration Open</Badge>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Create Tournament Modal */}
      <CreateTournamentModal
        isOpen={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        courses={courses}
        onSubmit={handleCreateTournament}
        loading={createLoading}
      />
    </div>
  );
}

// Create Tournament Modal Component
interface CreateTournamentModalProps {
  isOpen: boolean;
  onClose: () => void;
  courses: Course[];
  onSubmit: (data: any) => void;
  loading: boolean;
}

function CreateTournamentModal({ isOpen, onClose, courses, onSubmit, loading }: CreateTournamentModalProps) {
  const [formData, setFormData] = useState({
    courseId: '',
    name: '',
    description: '',
    format: 'STROKE',
    startDate: '',
    endDate: '',
    maxParticipants: '',
    minParticipants: '1',
    entryFee: '',
    handicapEnabled: 'false',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Create Tournament">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Course *
          </label>
          <select
            value={formData.courseId}
            onChange={(e) => handleInputChange('courseId', e.target.value)}
            required
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            <option value="">Select a course</option>
            {courses.map((course) => (
              <option key={course.id} value={course.id}>
                {course.name}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Tournament Name *
          </label>
          <Input
            value={formData.name}
            onChange={(e) => handleInputChange('name', e.target.value)}
            placeholder="Spring Championship"
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Description
          </label>
          <textarea
            value={formData.description}
            onChange={(e) => handleInputChange('description', e.target.value)}
            placeholder="Tournament description..."
            rows={3}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Format *
            </label>
            <select
              value={formData.format}
              onChange={(e) => handleInputChange('format', e.target.value)}
              required
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="STROKE">Stroke Play</option>
              <option value="MATCH_PLAY">Match Play</option>
              <option value="SCRAMBLE">Scramble</option>
              <option value="BEST_BALL">Best Ball</option>
              <option value="STABLEFORD">Stableford</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Entry Fee ($)
            </label>
            <Input
              type="number"
              value={formData.entryFee}
              onChange={(e) => handleInputChange('entryFee', e.target.value)}
              placeholder="0"
              min="0"
              step="0.01"
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Start Date *
            </label>
            <Input
              type="date"
              value={formData.startDate}
              onChange={(e) => handleInputChange('startDate', e.target.value)}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              End Date *
            </label>
            <Input
              type="date"
              value={formData.endDate}
              onChange={(e) => handleInputChange('endDate', e.target.value)}
              required
            />
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Min Participants
            </label>
            <Input
              type="number"
              value={formData.minParticipants}
              onChange={(e) => handleInputChange('minParticipants', e.target.value)}
              min="1"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Max Participants
            </label>
            <Input
              type="number"
              value={formData.maxParticipants}
              onChange={(e) => handleInputChange('maxParticipants', e.target.value)}
              placeholder="No limit"
              min="1"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Handicap Enabled
          </label>
          <select
            value={formData.handicapEnabled}
            onChange={(e) => handleInputChange('handicapEnabled', e.target.value)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-500 focus:ring-green-500"
          >
            <option value="false">No</option>
            <option value="true">Yes</option>
          </select>
        </div>

        <div className="flex justify-end space-x-3 pt-4">
          <Button type="button" variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Creating...' : 'Create Tournament'}
          </Button>
        </div>
      </form>
    </Modal>
  );
}