export type ScorecardStatus = 'IN_PROGRESS' | 'COMPLETED' | 'ABANDONED';

export interface HoleScore {
  id: string;
  holeNumber: number;
  par: number;
  strokes: number | null;
  putts: number | null;
  fairwayHit: boolean | null;
  greenInRegulation: boolean | null;
  penalties: number | null;
  scoreToPar: number | null;
  notes: string | null;
}

export interface Scorecard {
  id: string;
  golferProfile: {
    id: string;
    displayName: string;
    handicapIndex: number | null;
  };
  course: {
    id: string;
    name: string;
  };
  bookingId: string | null;
  playedOn: string;
  holesPlayed: number;
  totalStrokes: number | null;
  totalPutts: number | null;
  totalFairwaysHit: number | null;
  totalGreensInRegulation: number | null;
  totalPenalties: number | null;
  frontNineStrokes: number | null;
  backNineStrokes: number | null;
  scoreToPar: number | null;
  status: ScorecardStatus;
  teeColor: string | null;
  courseRating: number | null;
  slopeRating: number | null;
  notes: string | null;
  startedAt: string | null;
  completedAt: string | null;
  createdAt: string;
  holesCompleted: number;
  holeScores: HoleScore[];
}

export interface CourseHole {
  id: string;
  holeNumber: number;
  par: number;
  yardage: number | null;
  handicapIndex: number | null;
}
