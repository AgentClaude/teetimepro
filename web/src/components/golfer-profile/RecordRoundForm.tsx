import { useState, FormEvent } from 'react';
import { useMutation } from '@apollo/client';
import { Card, CardHeader } from '../ui/Card';
import { Button } from '../ui/Button';
import { RECORD_ROUND } from '../../graphql/golferProfile';

interface RecordRoundFormProps {
  profileId: string;
  onSuccess?: () => void;
  onCancel?: () => void;
}

export function RecordRoundForm({ profileId, onSuccess, onCancel }: RecordRoundFormProps) {
  const [courseName, setCourseName] = useState('');
  const [playedOn, setPlayedOn] = useState(new Date().toISOString().split('T')[0]);
  const [score, setScore] = useState('');
  const [holesPlayed, setHolesPlayed] = useState(18);
  const [courseRating, setCourseRating] = useState('');
  const [slopeRating, setSlopeRating] = useState('');
  const [teeColor, setTeeColor] = useState('');
  const [putts, setPutts] = useState('');
  const [fairwaysHit, setFairwaysHit] = useState('');
  const [greensInRegulation, setGreensInRegulation] = useState('');
  const [notes, setNotes] = useState('');
  const [showAdvanced, setShowAdvanced] = useState(false);

  const [recordRound, { loading, error }] = useMutation(RECORD_ROUND, {
    refetchQueries: ['GetGolferProfile', 'GetGolferRounds'],
  });

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    const variables: Record<string, unknown> = {
      golferProfileId: profileId,
      courseName,
      playedOn,
      score: parseInt(score, 10),
      holesPlayed,
    };

    if (courseRating) variables.courseRating = parseFloat(courseRating);
    if (slopeRating) variables.slopeRating = parseInt(slopeRating, 10);
    if (teeColor) variables.teeColor = teeColor;
    if (putts) variables.putts = parseInt(putts, 10);
    if (fairwaysHit) variables.fairwaysHit = parseInt(fairwaysHit, 10);
    if (greensInRegulation) variables.greensInRegulation = parseInt(greensInRegulation, 10);
    if (notes) variables.notes = notes;

    const result = await recordRound({ variables });

    if (result.data?.recordRound?.errors?.length === 0) {
      onSuccess?.();
    }
  };

  return (
    <Card>
      <CardHeader title="Record a Round" />
      <form onSubmit={handleSubmit} className="space-y-4 p-4">
        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2">
            <label className="block text-sm font-medium text-gray-700">Course Name *</label>
            <input
              type="text"
              value={courseName}
              onChange={(e) => setCourseName(e.target.value)}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Date Played *</label>
            <input
              type="date"
              value={playedOn}
              onChange={(e) => setPlayedOn(e.target.value)}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Score *</label>
            <input
              type="number"
              value={score}
              onChange={(e) => setScore(e.target.value)}
              min={18}
              max={200}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Holes</label>
            <select
              value={holesPlayed}
              onChange={(e) => setHolesPlayed(parseInt(e.target.value, 10))}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value={18}>18</option>
              <option value={9}>9</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Tee Color</label>
            <select
              value={teeColor}
              onChange={(e) => setTeeColor(e.target.value)}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
            >
              <option value="">Select...</option>
              <option value="black">Black</option>
              <option value="blue">Blue</option>
              <option value="white">White</option>
              <option value="gold">Gold</option>
              <option value="red">Red</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Course Rating</label>
            <input
              type="number"
              value={courseRating}
              onChange={(e) => setCourseRating(e.target.value)}
              step="0.1"
              min={55}
              max={85}
              placeholder="e.g., 72.5"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Slope Rating</label>
            <input
              type="number"
              value={slopeRating}
              onChange={(e) => setSlopeRating(e.target.value)}
              min={55}
              max={155}
              placeholder="e.g., 130"
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
            />
          </div>
        </div>

        <button
          type="button"
          onClick={() => setShowAdvanced(!showAdvanced)}
          className="text-sm text-green-600 hover:text-green-700"
        >
          {showAdvanced ? '− Hide' : '+ Show'} detailed stats
        </button>

        {showAdvanced && (
          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Putts</label>
              <input
                type="number"
                value={putts}
                onChange={(e) => setPutts(e.target.value)}
                min={0}
                max={100}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Fairways Hit</label>
              <input
                type="number"
                value={fairwaysHit}
                onChange={(e) => setFairwaysHit(e.target.value)}
                min={0}
                max={18}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">GIR</label>
              <input
                type="number"
                value={greensInRegulation}
                onChange={(e) => setGreensInRegulation(e.target.value)}
                min={0}
                max={18}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
              />
            </div>
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-gray-700">Notes</label>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            rows={2}
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm shadow-sm focus:border-green-500 focus:ring-green-500"
            placeholder="Any notes about this round..."
          />
        </div>

        {error && (
          <div className="rounded-md bg-red-50 p-3 text-sm text-red-700">
            {error.message}
          </div>
        )}

        <div className="flex justify-end gap-3">
          {onCancel && (
            <Button type="button" variant="outline" onClick={onCancel}>
              Cancel
            </Button>
          )}
          <Button type="submit" disabled={loading || !courseName || !score}>
            {loading ? 'Saving...' : 'Save Round'}
          </Button>
        </div>
      </form>
    </Card>
  );
}
