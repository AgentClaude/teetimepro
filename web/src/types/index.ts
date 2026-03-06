export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  fullName: string;
  role: "golfer" | "staff" | "pro_shop" | "manager" | "admin" | "owner";
  organizationId: string;
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

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
