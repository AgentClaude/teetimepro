import { useState } from 'react';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { SegmentFormModal } from '../components/segments/SegmentFormModal';
import { GET_GOLFER_SEGMENTS, GET_GOLFER_SEGMENT } from '../graphql/queries';
import { DELETE_GOLFER_SEGMENT } from '../graphql/mutations';

interface Segment {
  id: string;
  name: string;
  description: string | null;
  filterCriteria: Record<string, unknown>;
  isDynamic: boolean;
  cachedCount: number;
  lastEvaluatedAt: string | null;
  createdAt: string;
  createdBy: { id: string; fullName: string };
}

interface SegmentMember {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: string;
  createdAt: string;
}

const FILTER_LABELS: Record<string, string> = {
  booking_count_min: 'Min bookings',
  booking_count_max: 'Max bookings',
  last_booking_within_days: 'Booked within (days)',
  last_booking_before_days: 'Inactive for (days)',
  membership_tier: 'Membership tier',
  membership_status: 'Membership status',
  total_spent_min: 'Min spent',
  total_spent_max: 'Max spent',
  signup_within_days: 'Signed up within (days)',
  signup_before_days: 'Account older than (days)',
  handicap_min: 'Min handicap',
  handicap_max: 'Max handicap',
};

function formatFilterValue(key: string, value: unknown): string {
  if (key === 'total_spent_min' || key === 'total_spent_max') {
    return `$${((value as number) / 100).toFixed(0)}`;
  }
  if (Array.isArray(value)) {
    return value.join(', ');
  }
  return String(value);
}

export function SegmentsPage() {
  const [showForm, setShowForm] = useState(false);
  const [editingSegment, setEditingSegment] = useState<Segment | null>(null);
  const [selectedSegmentId, setSelectedSegmentId] = useState<string | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<string | null>(null);

  const { data, loading } = useQuery(GET_GOLFER_SEGMENTS);
  const segments: Segment[] = data?.golferSegments || [];

  const { data: detailData, loading: detailLoading } = useQuery(GET_GOLFER_SEGMENT, {
    variables: { id: selectedSegmentId },
    skip: !selectedSegmentId,
  });
  const selectedSegment = detailData?.golferSegment;
  const members: SegmentMember[] = selectedSegment?.members || [];

  const [deleteSegment] = useMutation(DELETE_GOLFER_SEGMENT, {
    refetchQueries: [{ query: GET_GOLFER_SEGMENTS }],
  });

  const handleDelete = async (id: string) => {
    await deleteSegment({ variables: { id } });
    setConfirmDelete(null);
    if (selectedSegmentId === id) setSelectedSegmentId(null);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-rough-900">Golfer Segments</h1>
          <p className="text-sm text-rough-500 mt-1">
            Create dynamic segments to target golfers for campaigns and marketing
          </p>
        </div>
        <Button onClick={() => { setEditingSegment(null); setShowForm(true); }}>
          + New Segment
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Segments list */}
        <div className="lg:col-span-1 space-y-3">
          {loading ? (
            <p className="text-sm text-rough-500">Loading segments...</p>
          ) : segments.length === 0 ? (
            <Card className="p-8 text-center">
              <div className="text-rough-400 mb-2">
                <svg className="w-12 h-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <p className="text-rough-500">No segments yet</p>
              <p className="text-sm text-rough-400 mt-1">Create your first segment to start targeting golfers</p>
            </Card>
          ) : (
            segments.map((seg) => (
              <Card
                key={seg.id}
                padding="sm"
                className={`cursor-pointer transition-all hover:shadow-md ${
                  selectedSegmentId === seg.id ? 'ring-2 ring-fairway-500' : ''
                }`}
                onClick={() => setSelectedSegmentId(seg.id)}
              >
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="font-medium text-rough-900">{seg.name}</h3>
                    {seg.description && (
                      <p className="text-xs text-rough-500 mt-0.5 line-clamp-1">{seg.description}</p>
                    )}
                  </div>
                  <Badge variant="info">{seg.cachedCount} golfers</Badge>
                </div>
                <div className="flex flex-wrap gap-1 mt-2">
                  {Object.entries(seg.filterCriteria).slice(0, 3).map(([key, val]) => (
                    <span
                      key={key}
                      className="inline-flex items-center px-2 py-0.5 rounded text-xs bg-rough-100 text-rough-600"
                    >
                      {FILTER_LABELS[key] || key}: {formatFilterValue(key, val)}
                    </span>
                  ))}
                  {Object.keys(seg.filterCriteria).length > 3 && (
                    <span className="text-xs text-rough-400">
                      +{Object.keys(seg.filterCriteria).length - 3} more
                    </span>
                  )}
                </div>
              </Card>
            ))
          )}
        </div>

        {/* Segment detail */}
        <div className="lg:col-span-2">
          {selectedSegmentId && selectedSegment ? (
            <Card>
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h2 className="text-xl font-semibold text-rough-900">{selectedSegment.name}</h2>
                  {selectedSegment.description && (
                    <p className="text-sm text-rough-500 mt-1">{selectedSegment.description}</p>
                  )}
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={() => {
                      setEditingSegment(selectedSegment);
                      setShowForm(true);
                    }}
                  >
                    Edit
                  </Button>
                  {confirmDelete === selectedSegmentId ? (
                    <div className="flex gap-1">
                      <Button variant="danger" size="sm" onClick={() => handleDelete(selectedSegmentId)}>
                        Confirm
                      </Button>
                      <Button variant="ghost" size="sm" onClick={() => setConfirmDelete(null)}>
                        Cancel
                      </Button>
                    </div>
                  ) : (
                    <Button variant="danger" size="sm" onClick={() => setConfirmDelete(selectedSegmentId)}>
                      Delete
                    </Button>
                  )}
                </div>
              </div>

              {/* Filter criteria */}
              <div className="mb-6">
                <h3 className="text-sm font-medium text-rough-700 mb-2">Filter Criteria</h3>
                <div className="flex flex-wrap gap-2">
                  {Object.entries(selectedSegment.filterCriteria).map(([key, val]) => (
                    <span
                      key={key}
                      className="inline-flex items-center px-3 py-1 rounded-full text-sm bg-fairway-50 text-fairway-700 border border-fairway-200"
                    >
                      {FILTER_LABELS[key] || key}: {formatFilterValue(key, val)}
                    </span>
                  ))}
                </div>
              </div>

              {/* Members table */}
              <div>
                <h3 className="text-sm font-medium text-rough-700 mb-2">
                  Members ({selectedSegment.cachedCount})
                </h3>
                {detailLoading ? (
                  <p className="text-sm text-rough-500">Loading members...</p>
                ) : members.length === 0 ? (
                  <p className="text-sm text-rough-400">No golfers match these criteria</p>
                ) : (
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-rough-200">
                      <thead>
                        <tr>
                          <th className="px-3 py-2 text-left text-xs font-medium text-rough-500 uppercase">Name</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-rough-500 uppercase">Email</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-rough-500 uppercase">Phone</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-rough-500 uppercase">Joined</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-rough-100">
                        {members.map((member) => (
                          <tr key={member.id} className="hover:bg-rough-50">
                            <td className="px-3 py-2 text-sm font-medium text-rough-900">{member.fullName}</td>
                            <td className="px-3 py-2 text-sm text-rough-600">{member.email}</td>
                            <td className="px-3 py-2 text-sm text-rough-600">{member.phone || '—'}</td>
                            <td className="px-3 py-2 text-sm text-rough-500">
                              {new Date(member.createdAt).toLocaleDateString()}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </Card>
          ) : (
            <Card className="p-12 text-center">
              <p className="text-rough-400">Select a segment to view details</p>
            </Card>
          )}
        </div>
      </div>

      {/* Form modal */}
      {showForm && (
        <SegmentFormModal
          isOpen={showForm}
          onClose={() => { setShowForm(false); setEditingSegment(null); }}
          segment={editingSegment}
        />
      )}
    </div>
  );
}
