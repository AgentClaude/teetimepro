import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQuery } from '@apollo/client';
import { Button } from '../ui/Button';
import { Input } from '../ui/Input';
import { Card } from '../ui/Card';
import { CREATE_SCORECARD } from '../../graphql/mutations';
import { GET_COURSES } from '../../graphql/queries';

const newScorecardSchema = z.object({
  courseId: z.string().min(1, 'Please select a course'),
  playedOn: z.string().min(1, 'Date is required'),
  holesPlayed: z.number().min(9).max(18),
  teeColor: z.string().optional(),
  courseRating: z
    .number()
    .min(55)
    .max(85)
    .optional()
    .or(z.nan().transform(() => undefined)),
  slopeRating: z
    .number()
    .min(55)
    .max(155)
    .optional()
    .or(z.nan().transform(() => undefined)),
  notes: z.string().max(500).optional(),
});

type NewScorecardFormData = z.infer<typeof newScorecardSchema>;

interface NewScorecardFormProps {
  golferProfileId: string;
  bookingId?: string;
  onCreated?: (scorecardId: string) => void;
  onCancel?: () => void;
}

const TEE_COLORS = ['White', 'Blue', 'Gold', 'Red', 'Black', 'Green'];

export function NewScorecardForm({
  golferProfileId,
  bookingId,
  onCreated,
  onCancel,
}: NewScorecardFormProps) {
  const [serverError, setServerError] = useState<string | null>(null);

  const { data: coursesData } = useQuery(GET_COURSES);
  const [createScorecard, { loading }] = useMutation(CREATE_SCORECARD);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<NewScorecardFormData>({
    resolver: zodResolver(newScorecardSchema),
    defaultValues: {
      playedOn: new Date().toISOString().split('T')[0],
      holesPlayed: 18,
      teeColor: 'White',
    },
  });

  const onSubmit = async (data: NewScorecardFormData) => {
    setServerError(null);

    try {
      const result = await createScorecard({
        variables: {
          golferProfileId,
          courseId: data.courseId,
          playedOn: data.playedOn,
          holesPlayed: data.holesPlayed,
          teeColor: data.teeColor || null,
          courseRating: data.courseRating || null,
          slopeRating: data.slopeRating || null,
          bookingId: bookingId || null,
          notes: data.notes || null,
        },
      });

      const response = result.data?.createScorecard;
      if (response?.errors?.length) {
        setServerError(response.errors.join(', '));
        return;
      }

      if (response?.scorecard?.id) {
        onCreated?.(response.scorecard.id);
      }
    } catch (err) {
      setServerError('Failed to create scorecard. Please try again.');
    }
  };

  const courses = coursesData?.courses ?? [];

  return (
    <Card className="p-6">
      <h2 className="text-lg font-bold text-rough-900 mb-4">New Scorecard</h2>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">Course</label>
          <select
            {...register('courseId')}
            className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm"
          >
            <option value="">Select a course...</option>
            {courses.map((c: { id: string; name: string }) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          {errors.courseId && (
            <p className="text-xs text-red-600 mt-1">{errors.courseId.message}</p>
          )}
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">Date</label>
            <Input type="date" {...register('playedOn')} error={errors.playedOn?.message} />
          </div>

          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">Holes</label>
            <select
              {...register('holesPlayed', { valueAsNumber: true })}
              className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm"
            >
              <option value={18}>18 Holes</option>
              <option value={9}>9 Holes</option>
            </select>
          </div>
        </div>

        <div className="grid grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">Tee Color</label>
            <select
              {...register('teeColor')}
              className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm"
            >
              {TEE_COLORS.map((color) => (
                <option key={color} value={color}>
                  {color}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Course Rating
            </label>
            <Input
              type="number"
              step="0.1"
              placeholder="72.1"
              {...register('courseRating', { valueAsNumber: true })}
              error={errors.courseRating?.message}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-rough-700 mb-1">
              Slope Rating
            </label>
            <Input
              type="number"
              placeholder="131"
              {...register('slopeRating', { valueAsNumber: true })}
              error={errors.slopeRating?.message}
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-rough-700 mb-1">Notes</label>
          <textarea
            {...register('notes')}
            rows={2}
            placeholder="Any notes about this round..."
            className="w-full rounded-md border border-rough-300 px-3 py-2 text-sm"
          />
        </div>

        {serverError && (
          <div className="bg-red-50 text-red-700 rounded-md p-3 text-sm">{serverError}</div>
        )}

        <div className="flex gap-3 justify-end">
          {onCancel && (
            <Button type="button" variant="secondary" onClick={onCancel}>
              Cancel
            </Button>
          )}
          <Button type="submit" variant="primary" loading={loading}>
            Start Round
          </Button>
        </div>
      </form>
    </Card>
  );
}
