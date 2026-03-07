import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { useQuery, useMutation } from '@apollo/client';
import { Card } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Input } from '../components/ui/Input';
import { LoadingSpinner } from '../components/ui/LoadingSpinner';
import { 
  GET_PUBLIC_COURSE, 
  GET_PUBLIC_AVAILABLE_TEE_TIMES, 
  CREATE_PUBLIC_BOOKING 
} from '../graphql/public';
import { formatCents, formatDate } from '../lib/utils';
import {
  CalendarDaysIcon,
  ClockIcon,
  UserGroupIcon,
  PhoneIcon,
  EnvelopeIcon,
  MapPinIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline';

interface Course {
  id: string;
  name: string;
  slug: string;
  holes: number;
  address: string;
  phone: string;
  weekdayRateCents: number;
  weekendRateCents: number;
  twilightRateCents: number;
}

interface TeeTime {
  id: string;
  startsAt: string;
  formattedTime: string;
  maxPlayers: number;
  bookedPlayers: number;
  availableSpots: number;
  priceCents: number;
}

interface Booking {
  id: string;
  confirmationCode: string;
  status: string;
  playersCount: number;
  totalCents: number;
  teeTime: {
    formattedTime: string;
    startsAt: string;
  };
  user: {
    firstName: string;
    lastName: string;
    email: string;
  };
}

const TIME_PREFERENCES = [
  { value: '', label: 'Any time' },
  { value: 'morning', label: 'Morning (Before 12 PM)' },
  { value: 'afternoon', label: 'Afternoon (12-4 PM)' },
  { value: 'twilight', label: 'Twilight (After 4 PM)' }
];

export function PublicBookingPage() {
  const { courseSlug } = useParams();
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedPlayers, setSelectedPlayers] = useState(2);
  const [timePreference, setTimePreference] = useState('');
  const [selectedTeeTime, setSelectedTeeTime] = useState<TeeTime | null>(null);
  const [customerInfo, setCustomerInfo] = useState({
    name: '',
    email: '',
    phone: ''
  });
  const [completedBooking, setCompletedBooking] = useState<Booking | null>(null);

  // Use courseSlug from params or default
  const slug = courseSlug || 'default-course';

  const { data: courseData, loading: courseLoading } = useQuery<{
    publicCourse: Course;
  }>(GET_PUBLIC_COURSE, {
    variables: { slug },
    skip: !slug
  });

  const { data: teeTimesData, loading: teeTimesLoading, refetch: refetchTeeTimes } = useQuery<{
    publicAvailableTeeTimes: TeeTime[];
  }>(GET_PUBLIC_AVAILABLE_TEE_TIMES, {
    variables: {
      courseSlug: slug,
      date: selectedDate,
      players: selectedPlayers,
      timePreference: timePreference || undefined
    },
    skip: !slug || !selectedDate
  });

  const [createBooking, { loading: bookingLoading }] = useMutation(CREATE_PUBLIC_BOOKING, {
    onCompleted: (data) => {
      if (data.createPublicBooking.booking) {
        setCompletedBooking(data.createPublicBooking.booking);
      }
    }
  });

  // Refetch tee times when filters change
  useEffect(() => {
    if (slug && selectedDate) {
      refetchTeeTimes();
    }
  }, [selectedDate, selectedPlayers, timePreference, refetchTeeTimes, slug]);

  const course = courseData?.publicCourse;
  const teeTimes = teeTimesData?.publicAvailableTeeTimes || [];

  const handleTeeTimeSelect = (teeTime: TeeTime) => {
    setSelectedTeeTime(teeTime);
  };

  const handleBookingSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedTeeTime || !course) return;

    try {
      await createBooking({
        variables: {
          courseSlug: course.slug,
          teeTimeId: selectedTeeTime.id,
          playersCount: selectedPlayers,
          customerName: customerInfo.name,
          customerEmail: customerInfo.email,
          customerPhone: customerInfo.phone
        }
      });
    } catch (error) {
      console.error('Booking failed:', error);
    }
  };

  // Show completed booking screen
  if (completedBooking) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-fairway-50 to-white">
        <div className="mx-auto max-w-2xl px-4 py-16">
          <div className="text-center">
            <CheckCircleIcon className="mx-auto h-16 w-16 text-green-500" />
            <h1 className="mt-4 text-3xl font-bold text-rough-900">Booking Confirmed!</h1>
            <p className="mt-2 text-rough-600">Your tee time has been successfully reserved.</p>
          </div>

          <Card className="mt-8">
            <div className="p-6">
              <h2 className="text-xl font-semibold text-rough-900 mb-4">Booking Details</h2>
              
              <div className="space-y-3">
                <div className="flex justify-between">
                  <span className="text-rough-600">Confirmation Code</span>
                  <span className="font-medium text-rough-900">{completedBooking.confirmationCode}</span>
                </div>
                
                <div className="flex justify-between">
                  <span className="text-rough-600">Course</span>
                  <span className="font-medium text-rough-900">{course?.name}</span>
                </div>
                
                <div className="flex justify-between">
                  <span className="text-rough-600">Date & Time</span>
                  <span className="font-medium text-rough-900">
                    {formatDate(selectedDate)} at {completedBooking.teeTime.formattedTime}
                  </span>
                </div>
                
                <div className="flex justify-between">
                  <span className="text-rough-600">Players</span>
                  <span className="font-medium text-rough-900">{completedBooking.playersCount}</span>
                </div>
                
                <div className="flex justify-between">
                  <span className="text-rough-600">Total</span>
                  <span className="font-medium text-rough-900">{formatCents(completedBooking.totalCents)}</span>
                </div>
                
                <div className="border-t pt-3 mt-3">
                  <div className="text-sm text-rough-600">
                    <p>Name: {completedBooking.user.firstName} {completedBooking.user.lastName}</p>
                    <p>Email: {completedBooking.user.email}</p>
                  </div>
                </div>
              </div>

              <div className="mt-6 p-4 bg-green-50 rounded-lg">
                <p className="text-sm text-green-800">
                  A confirmation email has been sent to {completedBooking.user.email}. 
                  Please arrive 15 minutes before your tee time.
                </p>
              </div>
            </div>
          </Card>
        </div>
      </div>
    );
  }

  if (courseLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!course) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-rough-900">Course Not Found</h1>
          <p className="mt-2 text-rough-600">The golf course you're looking for doesn't exist.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-fairway-50 to-white">
      <div className="mx-auto max-w-4xl px-4 py-8">
        {/* Header */}
        <div className="text-center mb-8">
          <span className="text-6xl">⛳</span>
          <h1 className="mt-4 text-4xl font-bold text-rough-900">Book Your Tee Time</h1>
          <h2 className="text-2xl font-semibold text-fairway-600 mt-2">{course.name}</h2>
          
          {course.address && (
            <div className="flex items-center justify-center mt-2 text-rough-600">
              <MapPinIcon className="h-4 w-4 mr-1" />
              <span className="text-sm">{course.address}</span>
            </div>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Booking Form */}
          <div className="lg:col-span-2">
            <Card>
              <div className="p-6">
                <h3 className="text-lg font-semibold text-rough-900 mb-4">Select Your Preferences</h3>
                
                {/* Date and Players Selection */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                  <div>
                    <label className="block text-sm font-medium text-rough-700 mb-2">
                      <CalendarDaysIcon className="inline h-4 w-4 mr-1" />
                      Date
                    </label>
                    <Input
                      type="date"
                      value={selectedDate}
                      onChange={(e) => setSelectedDate(e.target.value)}
                      min={new Date().toISOString().split('T')[0]}
                    />
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-rough-700 mb-2">
                      <UserGroupIcon className="inline h-4 w-4 mr-1" />
                      Players
                    </label>
                    <select
                      value={selectedPlayers}
                      onChange={(e) => setSelectedPlayers(Number(e.target.value))}
                      className="w-full rounded-lg border-rough-300 px-3 py-2 text-sm focus:border-fairway-500 focus:ring-fairway-500"
                    >
                      {[1, 2, 3, 4].map(num => (
                        <option key={num} value={num}>{num} Player{num !== 1 ? 's' : ''}</option>
                      ))}
                    </select>
                  </div>
                </div>

                {/* Time Preference */}
                <div className="mb-6">
                  <label className="block text-sm font-medium text-rough-700 mb-2">
                    <ClockIcon className="inline h-4 w-4 mr-1" />
                    Time Preference
                  </label>
                  <select
                    value={timePreference}
                    onChange={(e) => setTimePreference(e.target.value)}
                    className="w-full rounded-lg border-rough-300 px-3 py-2 text-sm focus:border-fairway-500 focus:ring-fairway-500"
                  >
                    {TIME_PREFERENCES.map(pref => (
                      <option key={pref.value} value={pref.value}>{pref.label}</option>
                    ))}
                  </select>
                </div>

                {/* Available Tee Times */}
                <h4 className="text-md font-semibold text-rough-900 mb-3">Available Tee Times</h4>
                
                {teeTimesLoading ? (
                  <div className="flex justify-center py-8">
                    <LoadingSpinner size="md" />
                  </div>
                ) : teeTimes.length === 0 ? (
                  <div className="text-center py-8 text-rough-600">
                    <ClockIcon className="mx-auto h-12 w-12 text-rough-400 mb-2" />
                    <p>No available tee times for the selected date and preferences.</p>
                    <p className="text-sm mt-1">Try selecting a different date or time preference.</p>
                  </div>
                ) : (
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                    {teeTimes.map(teeTime => (
                      <button
                        key={teeTime.id}
                        onClick={() => handleTeeTimeSelect(teeTime)}
                        className={`p-3 rounded-lg border text-left transition-colors ${
                          selectedTeeTime?.id === teeTime.id
                            ? 'border-fairway-500 bg-fairway-50 ring-1 ring-fairway-500'
                            : 'border-rough-200 hover:border-fairway-300 hover:bg-fairway-25'
                        }`}
                      >
                        <div className="font-medium text-rough-900">{teeTime.formattedTime}</div>
                        <div className="text-sm text-rough-600">
                          {teeTime.availableSpots} spots • {formatCents(teeTime.priceCents)}/player
                        </div>
                      </button>
                    ))}
                  </div>
                )}

                {/* Customer Information */}
                {selectedTeeTime && (
                  <form onSubmit={handleBookingSubmit} className="mt-8 pt-6 border-t">
                    <h4 className="text-md font-semibold text-rough-900 mb-3">Your Information</h4>
                    
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-rough-700 mb-2">
                          Full Name *
                        </label>
                        <Input
                          required
                          value={customerInfo.name}
                          onChange={(e) => setCustomerInfo({...customerInfo, name: e.target.value})}
                          placeholder="John Smith"
                        />
                      </div>
                      
                      <div>
                        <label className="block text-sm font-medium text-rough-700 mb-2">
                          <PhoneIcon className="inline h-4 w-4 mr-1" />
                          Phone Number *
                        </label>
                        <Input
                          required
                          type="tel"
                          value={customerInfo.phone}
                          onChange={(e) => setCustomerInfo({...customerInfo, phone: e.target.value})}
                          placeholder="(555) 123-4567"
                        />
                      </div>
                    </div>
                    
                    <div className="mt-4">
                      <label className="block text-sm font-medium text-rough-700 mb-2">
                        <EnvelopeIcon className="inline h-4 w-4 mr-1" />
                        Email Address *
                      </label>
                      <Input
                        required
                        type="email"
                        value={customerInfo.email}
                        onChange={(e) => setCustomerInfo({...customerInfo, email: e.target.value})}
                        placeholder="john@example.com"
                      />
                    </div>

                    <Button
                      type="submit"
                      loading={bookingLoading}
                      fullWidth
                      className="mt-6"
                      size="lg"
                    >
                      Confirm Booking - {formatCents(selectedTeeTime.priceCents * selectedPlayers)}
                    </Button>
                  </form>
                )}
              </div>
            </Card>
          </div>

          {/* Course Info Sidebar */}
          <div>
            <Card>
              <div className="p-6">
                <h3 className="text-lg font-semibold text-rough-900 mb-4">Course Information</h3>
                
                <div className="space-y-3 text-sm">
                  <div className="flex justify-between">
                    <span className="text-rough-600">Holes</span>
                    <span className="text-rough-900">{course.holes}</span>
                  </div>
                  
                  {course.phone && (
                    <div className="flex justify-between">
                      <span className="text-rough-600">Phone</span>
                      <span className="text-rough-900">{course.phone}</span>
                    </div>
                  )}
                  
                  {course.weekdayRateCents && (
                    <div className="space-y-2 pt-2 border-t">
                      <div className="font-medium text-rough-700">Rates</div>
                      <div className="flex justify-between">
                        <span className="text-rough-600">Weekday</span>
                        <span className="text-rough-900">{formatCents(course.weekdayRateCents)}</span>
                      </div>
                      {course.weekendRateCents && (
                        <div className="flex justify-between">
                          <span className="text-rough-600">Weekend</span>
                          <span className="text-rough-900">{formatCents(course.weekendRateCents)}</span>
                        </div>
                      )}
                      {course.twilightRateCents && (
                        <div className="flex justify-between">
                          <span className="text-rough-600">Twilight</span>
                          <span className="text-rough-900">{formatCents(course.twilightRateCents)}</span>
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}