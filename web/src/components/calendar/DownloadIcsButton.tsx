import { useState } from 'react';
import { CalendarDaysIcon } from '@heroicons/react/24/outline';
import { Button } from '../ui/Button';

interface Booking {
  id: string;
  confirmationCode: string;
  startsAt: string;
  course: {
    name: string;
    address?: string;
    city?: string;
    state?: string;
    zipCode?: string;
  };
  playersCount: number;
  notes?: string;
  bookingPlayers: Array<{
    name: string;
  }>;
}

interface DownloadIcsButtonProps {
  booking: Booking;
  variant?: 'default' | 'outline' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  showText?: boolean;
}

export function DownloadIcsButton({ 
  booking, 
  variant = 'outline', 
  size = 'sm',
  showText = true 
}: DownloadIcsButtonProps) {
  const [isDownloading, setIsDownloading] = useState(false);

  const handleDownload = async () => {
    setIsDownloading(true);
    
    try {
      const response = await fetch(`/api/bookings/${booking.id}/ics`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/calendar',
        },
        credentials: 'include',
      });

      if (!response.ok) {
        throw new Error('Failed to generate ICS file');
      }

      const icsContent = await response.text();
      const blob = new Blob([icsContent], { type: 'text/calendar' });
      const url = URL.createObjectURL(blob);

      // Create filename
      const date = new Date(booking.startsAt).toISOString().split('T')[0].replace(/-/g, '');
      const courseName = booking.course.name.replace(/[^a-z0-9]/gi, '-').toLowerCase();
      const filename = `golf-booking-${courseName}-${date}.ics`;

      // Trigger download
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error('Error downloading ICS file:', error);
      // In a real app, you'd show a toast notification here
      alert('Failed to download calendar file. Please try again.');
    } finally {
      setIsDownloading(false);
    }
  };

  return (
    <Button
      variant={variant}
      size={size}
      onClick={handleDownload}
      disabled={isDownloading}
      className="gap-2"
    >
      <CalendarDaysIcon className={`${size === 'sm' ? 'h-4 w-4' : 'h-5 w-5'}`} />
      {showText && (
        <span>{isDownloading ? 'Generating...' : 'Add to Calendar'}</span>
      )}
    </Button>
  );
}

// For use in booking confirmation flows
export function BookingCalendarDownload({ booking }: { booking: Booking }) {
  return (
    <div className="flex flex-col space-y-2 rounded-lg bg-blue-50 p-4">
      <h4 className="text-sm font-medium text-blue-900">Add to Calendar</h4>
      <p className="text-xs text-blue-700">
        Download an ICS file to add this booking to your calendar app
      </p>
      <div className="flex justify-start">
        <DownloadIcsButton 
          booking={booking} 
          variant="default" 
          size="sm"
          showText={true}
        />
      </div>
    </div>
  );
}