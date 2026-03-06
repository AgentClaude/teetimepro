export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName: string;
  role: "golfer" | "staff" | "pro_shop" | "manager" | "admin" | "owner";
  organizationId: string;
}

export interface VoiceConfig {
  system_prompt?: string;
  greeting?: string;
  voice_model?: string;
  llm_provider?: string;
  llm_model?: string;
}

export interface Course {
  id: string;
  name: string;
  holes: number;
  intervalMinutes: number;
  maxPlayersPerSlot: number;
  firstTeeTime: string;
  lastTeeTime: string;
  weekdayRateCents: number | null;
  weekendRateCents: number | null;
  twilightRateCents: number | null;
  address: string | null;
  phone: string | null;
  voiceConfig: VoiceConfig;
}

export interface TeeSheet {
  id: string;
  date: string;
  courseId: string;
  totalSlots: number;
  availableSlots: number;
  utilizationPercentage: number;
  teeTimes: TeeTime[];
  course: Course;
}

export type TeeTimeStatus =
  | "available"
  | "partially_booked"
  | "fully_booked"
  | "blocked"
  | "maintenance";

export interface TeeTime {
  id: string;
  startsAt: string;
  formattedTime: string;
  status: TeeTimeStatus;
  maxPlayers: number;
  bookedPlayers: number;
  availableSpots: number;
  priceCents: number | null;
  notes: string | null;
  bookings: Booking[];
}

export interface Booking {
  id: string;
  confirmationCode: string;
  status: "confirmed" | "checked_in" | "completed" | "cancelled" | "no_show";
  playersCount: number;
  totalCents: number;
  cancellable: boolean;
  cancelledAt: string | null;
  cancellationReason: string | null;
  createdAt: string;
  teeTime: TeeTime;
  user: User;
  bookingPlayers: BookingPlayer[];
}

export interface BookingPlayer {
  id: string;
  name: string;
  handicap: number | null;
}

export interface VoiceCallLogSummary {
  message_count: number;
  user_messages: number;
  agent_messages: number;
  function_calls: number;
  booking_created: boolean;
  confirmation_code: string | null;
  booking_id: number | null;
  booking_status: string | null;
  booking_players: number | null;
  booking_time: string | null;
  booking_date: string | null;
}

export interface TranscriptEntry {
  type: "transcript" | "function_call" | "function_result";
  timestamp: string;
  role?: string;
  content?: string;
  name?: string;
  arguments?: string;
  result?: Record<string, unknown>;
}

export interface VoiceCallLog {
  id: string;
  courseId: string | null;
  courseName: string | null;
  callSid: string | null;
  channel: "browser" | "twilio";
  callerPhone: string | null;
  callerName: string | null;
  status: string;
  durationSeconds: number | null;
  transcript: TranscriptEntry[];
  summary: VoiceCallLogSummary;
  startedAt: string;
  endedAt: string | null;
  createdAt: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
