import { useState } from 'react';
import { useMutation } from '@apollo/client';
import { Modal } from '../ui/Modal';
import { Button } from '../ui/Button';
import { SegmentFilterBuilder, type FilterCriteria } from './SegmentFilterBuilder';
import { CREATE_GOLFER_SEGMENT, UPDATE_GOLFER_SEGMENT } from '../../graphql/mutations';
import { GET_GOLFER_SEGMENTS } from '../../graphql/queries';

interface Segment {
  id: string;
  name: string;
  description: string | null;
  filterCriteria: Record<string, unknown>;
  isDynamic: boolean;
}

interface SegmentFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  segment?: Segment | null;
}

export function SegmentFormModal({ isOpen, onClose, segment }: SegmentFormModalProps) {
  const isEditing = !!segment;
  const [name, setName] = useState(segment?.name ?? '');
  const [description, setDescription] = useState(segment?.description ?? '');
  const [filterCriteria, setFilterCriteria] = useState<FilterCriteria>(
    (segment?.filterCriteria ?? {}) as FilterCriteria
  );
  const [errors, setErrors] = useState<string[]>([]);

  const [createSegment, { loading: creating }] = useMutation(CREATE_GOLFER_SEGMENT, {
    refetchQueries: [{ query: GET_GOLFER_SEGMENTS }],
  });

  const [updateSegment, { loading: updating }] = useMutation(UPDATE_GOLFER_SEGMENT, {
    refetchQueries: [{ query: GET_GOLFER_SEGMENTS }],
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrors([]);

    const nonEmptyCriteria = Object.fromEntries(
      Object.entries(filterCriteria).filter(
        ([, v]) => v !== undefined && v !== '' && !(Array.isArray(v) && v.length === 0)
      )
    );

    if (Object.keys(nonEmptyCriteria).length === 0) {
      setErrors(['At least one filter is required']);
      return;
    }

    try {
      if (isEditing && segment) {
        const { data } = await updateSegment({
          variables: {
            id: segment.id,
            name,
            description: description || null,
            filterCriteria: nonEmptyCriteria,
          },
        });
        if (data?.updateGolferSegment?.errors?.length > 0) {
          setErrors(data.updateGolferSegment.errors);
          return;
        }
      } else {
        const { data } = await createSegment({
          variables: {
            name,
            description: description || null,
            filterCriteria: nonEmptyCriteria,
            isDynamic: true,
          },
        });
        if (data?.createGolferSegment?.errors?.length > 0) {
          setErrors(data.createGolferSegment.errors);
          return;
        }
      }
      onClose();
    } catch (err) {
      setErrors([(err as Error).message]);
    }
  };

  const loading = creating || updating;

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={isEditing ? 'Edit Segment' : 'Create Segment'} size="lg">
      <form onSubmit={handleSubmit} className="space-y-4">
        {errors.length > 0 && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-3">
            {errors.map((err, i) => (
              <p key={i} className="text-sm text-red-600">{err}</p>
            ))}
          </div>
        )}

        <div>
          <label htmlFor="segment-name" className="block text-sm font-medium text-rough-700 mb-1">
            Segment Name
          </label>
          <input
            id="segment-name"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g., High-value members, Lapsed golfers"
            required
            className="block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          />
        </div>

        <div>
          <label htmlFor="segment-desc" className="block text-sm font-medium text-rough-700 mb-1">
            Description (optional)
          </label>
          <textarea
            id="segment-desc"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            rows={2}
            placeholder="Describe this segment's purpose..."
            className="block w-full rounded-md border-rough-300 shadow-sm focus:border-fairway-500 focus:ring-fairway-500"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-rough-700 mb-2">Filters</label>
          <SegmentFilterBuilder value={filterCriteria} onChange={setFilterCriteria} />
        </div>

        <div className="flex justify-end gap-3 pt-4 border-t border-rough-200">
          <Button type="button" variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" loading={loading}>
            {isEditing ? 'Update Segment' : 'Create Segment'}
          </Button>
        </div>
      </form>
    </Modal>
  );
}
