import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQuery } from '@apollo/client';
import { gql } from '@apollo/client';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { LoadingSpinner } from '../ui/LoadingSpinner';

// ─── GraphQL ────────────────────────────────────────────────────────────────

export const CREATE_WALK_ON_BOOKING = gql`
  mutation CreateWalkOnBooking(
    $teeTimeId: ID
    $courseId: ID
    $playersCount: Int!
    $guestName: String!
    $guestEmail: String
    $guestPhone: String
    $walkOnNotes: String
  ) {
    createWalkOnBooking(
      teeTimeId: $teeTimeId
      courseId: $courseId
      playersCount: $playersCount
      guestName: $guestName
      guestEmail: $guestEmail
      guestPhone: $guestPhone
      walkOnNotes: $walkOnNotes
    ) {
      booking {
        id
        confirmationCode
        bookingType
        guestName
        guestEmail
        guestPhone
        walkOnNotes
        isWalkOn
        playersCount
        status
        totalCents
        teeTime {
          id
          startsAt
        }
      }
      teeTime {
        id
        startsAt
        availableSpots
      }
      errors
    }
  }
`;

const GET_COURSES = gql`
  query GetCourses {
    courses {
      id
      name
    }
  }
`;

// ─── Schema ─────────────────────────────────────────────────────────────────

const walkOnFormSchema = z.object({
  guestName: z.string().min(1, 'Guest name is required'),
  guestEmail: z.string().email('Invalid email').or(z.literal('')).optional(),
  guestPhone: z.string().optional(),
  playersCount: z.number().min(1, 'At least 1 player').max(4, 'Maximum 4 players'),
  walkOnNotes: z.string().max(500).optional(),
});

type WalkOnFormData = z.infer<typeof walkOnFormSchema>;

// ─── Types ──────────────────────────────────────────────────────────────────

interface WalkOnBookingResult {
  id: string;
  confirmationCode: string;
  bookingType: string;
  guestName: string;
  playersCount: number;
  status: string;
  totalCents: number;
  teeTime: {
    id: string;
    startsAt: string;
  };
}

export interface WalkOnBookingFormProps {
  /** Pre-selected tee time ID */
  teeTimeId?: string;
  /** Course ID for auto-assign mode */
  courseId?: string;
  /** Available courses for selection */
  courses?: Array<{ id: string; name: string }>;
  /** Callback after successful booking */
  onBookingComplete?: (booking: WalkOnBookingResult) => void;
  /** Cancel handler */
  onCancel?: () => void;
  /** Tee time display info (when teeTimeId is provided) */
  teeTimeInfo?: {
    startsAt: string;
    courseName: string;
    availableSpots: number;
  };
}

// ─── Component ──────────────────────────────────────────────────────────────

export function WalkOnBookingForm({
  teeTimeId,
  courseId: initialCourseId,
  courses: propCourses,
  onBookingComplete,
  onCancel,
  teeTimeInfo,
}: WalkOnBookingFormProps) {
  const [selectedCourseId, setSelectedCourseId] = useState(initialCourseId ?? '');
  const [completedBooking, setCompletedBooking] = useState<WalkOnBookingResult | null>(null);

  const { data: coursesData } = useQuery(GET_COURSES, {
    skip: !!propCourses || !!teeTimeId,
  });

  const courses = propCourses ?? coursesData?.courses ?? [];

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<WalkOnFormData>({
    resolver: zodResolver(walkOnFormSchema),
    defaultValues: {
      guestName: '',
      guestEmail: '',
      guestPhone: '',
      playersCount: 1,
      walkOnNotes: '',
    },
  });

  const [createWalkOn, { loading, error: mutationError }] = useMutation(CREATE_WALK_ON_BOOKING);

  const onSubmit = async (data: WalkOnFormData) => {
    const variables: Record<string, unknown> = {
      playersCount: data.playersCount,
      guestName: data.guestName,
      guestEmail: data.guestEmail || undefined,
      guestPhone: data.guestPhone || undefined,
      walkOnNotes: data.walkOnNotes || undefined,
    };

    if (teeTimeId) {
      variables.teeTimeId = teeTimeId;
    } else {
      variables.courseId = selectedCourseId;
    }

    const result = await createWalkOn({ variables });
    const response = result.data?.createWalkOnBooking;

    if (response?.errors?.length > 0) {
      return; // errors shown via mutationError
    }

    if (response?.booking) {
      setCompletedBooking(response.booking);
      onBookingComplete?.(response.booking);
    }
  };

  // ─── Success State ──────────────────────────────────────────────────────

  if (completedBooking) {
    return (
      <div className="rounded-lg border border-green-200 bg-green-50 p-6">
        <div className="flex items-center gap-2 mb-4">
          <svg className="h-6 w-6 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
          </svg>
          <h3 className="text-lg font-semibold text-green-800">Walk-On Booked!</h3>
        </div>
        <dl className="space-y-2 text-sm">
          <div className="flex justify-between">
            <dt className="text-gray-600">Confirmation Code</dt>
            <dd className="font-mono font-bold text-green-700">{completedBooking.confirmationCode}</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-gray-600">Guest</dt>
            <dd>{completedBooking.guestName}</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-gray-600">Players</dt>
            <dd>{completedBooking.playersCount}</dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-gray-600">Tee Time</dt>
            <dd>{new Date(completedBooking.teeTime.startsAt).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}</dd>
          </div>
        </dl>
        <div className="mt-4 flex gap-2">
          <Button
            variant="outline"
            onClick={() => {
              setCompletedBooking(null);
            }}
          >
            Book Another Walk-On
          </Button>
          {onCancel && (
            <Button variant="ghost" onClick={onCancel}>
              Done
            </Button>
          )}
        </div>
      </div>
    );
  }

  // ─── Form ───────────────────────────────────────────────────────────────

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="flex items-center gap-2 mb-2">
        <div className="rounded-full bg-amber-100 p-1.5">
          <svg className="h-5 w-5 text-amber-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>
        <h3 className="text-lg font-semibold">Walk-On Booking</h3>
      </div>

      {teeTimeInfo && (
        <div className="rounded-md bg-blue-50 border border-blue-200 p-3 text-sm">
          <p className="font-medium text-blue-800">{teeTimeInfo.courseName}</p>
          <p className="text-blue-600">
            {new Date(teeTimeInfo.startsAt).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' })}
            {' · '}
            {teeTimeInfo.availableSpots} spot{teeTimeInfo.availableSpots !== 1 ? 's' : ''} available
          </p>
        </div>
      )}

      {!teeTimeId && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Course <span className="text-xs text-gray-500">(will find next available tee time)</span>
          </label>
          <select
            value={selectedCourseId}
            onChange={(e) => setSelectedCourseId(e.target.value)}
            className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:ring-green-500"
            required
          >
            <option value="">Select a course...</option>
            {courses.map((course: { id: string; name: string }) => (
              <option key={course.id} value={course.id}>
                {course.name}
              </option>
            ))}
          </select>
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Guest Name <span className="text-red-500">*</span>
        </label>
        <Input
          {...register('guestName')}
          placeholder="e.g. John Smith"
          error={errors.guestName?.message}
        />
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <Input
            {...register('guestEmail')}
            type="email"
            placeholder="john@example.com"
            error={errors.guestEmail?.message}
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
          <Input
            {...register('guestPhone')}
            type="tel"
            placeholder="+1 555 123 4567"
            error={errors.guestPhone?.message}
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Number of Players
        </label>
        <select
          {...register('playersCount', { valueAsNumber: true })}
          className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:ring-green-500"
        >
          {[1, 2, 3, 4].map((n) => (
            <option key={n} value={n}>
              {n} player{n > 1 ? 's' : ''}
            </option>
          ))}
        </select>
        {errors.playersCount && (
          <p className="mt-1 text-sm text-red-600">{errors.playersCount.message}</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Notes <span className="text-xs text-gray-500">(equipment rental, special requests, etc.)</span>
        </label>
        <textarea
          {...register('walkOnNotes')}
          rows={2}
          className="w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-green-500 focus:ring-green-500"
          placeholder="e.g. Needs rental clubs, first time playing"
        />
      </div>

      {mutationError && (
        <div className="rounded-md bg-red-50 border border-red-200 p-3 text-sm text-red-700">
          {mutationError.message}
        </div>
      )}

      <div className="flex gap-2 pt-2">
        <Button type="submit" disabled={loading} className="flex-1">
          {loading ? <LoadingSpinner size="sm" /> : 'Book Walk-On'}
        </Button>
        {onCancel && (
          <Button type="button" variant="outline" onClick={onCancel}>
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
