import React from 'react';
import {
  CalendarIcon,
  XCircleIcon,
  CheckIcon,
  ClockIcon,
  CheckCircleIcon,
} from '@heroicons/react/24/outline';
import { formatDistanceToNow } from 'date-fns';

interface RecentActivity {
  id: string;
  activityType: 'booked' | 'cancelled' | 'checked_in' | 'completed' | 'no_show';
  confirmationCode: string;
  userName: string;
  courseName: string;
  teeTime: string;
  playersCount: number;
  occurredAt: string;
}

interface RecentActivityFeedProps {
  activities: RecentActivity[];
  loading: boolean;
}

const getActivityIcon = (activityType: string) => {
  const iconClasses = "h-5 w-5";
  
  switch (activityType) {
    case 'booked':
      return <CalendarIcon className={`${iconClasses} text-green-500`} />;
    case 'cancelled':
      return <XCircleIcon className={`${iconClasses} text-red-500`} />;
    case 'checked_in':
      return <CheckIcon className={`${iconClasses} text-green-500`} />;
    case 'completed':
      return <CheckCircleIcon className={`${iconClasses} text-blue-500`} />;
    case 'no_show':
      return <ClockIcon className={`${iconClasses} text-red-500`} />;
    default:
      return <CalendarIcon className={`${iconClasses} text-gray-500`} />;
  }
};

const getActivityColor = (activityType: string) => {
  switch (activityType) {
    case 'booked':
    case 'checked_in':
      return 'text-green-700 bg-green-100';
    case 'cancelled':
    case 'no_show':
      return 'text-red-700 bg-red-100';
    case 'completed':
      return 'text-blue-700 bg-blue-100';
    default:
      return 'text-gray-700 bg-gray-100';
  }
};

const getActivityText = (activityType: string) => {
  switch (activityType) {
    case 'booked':
      return 'New booking';
    case 'cancelled':
      return 'Cancelled';
    case 'checked_in':
      return 'Checked in';
    case 'completed':
      return 'Completed';
    case 'no_show':
      return 'No show';
    default:
      return 'Activity';
  }
};

const formatTeeTime = (teeTime: string) => {
  const date = new Date(teeTime);
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true
  });
};

const RecentActivityFeed: React.FC<RecentActivityFeedProps> = ({ activities, loading }) => {
  if (loading) {
    return (
      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="animate-pulse flex items-center space-x-3">
              <div className="h-10 w-10 bg-gray-200 rounded-full"></div>
              <div className="flex-1">
                <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-1/2"></div>
              </div>
              <div className="h-3 bg-gray-200 rounded w-16"></div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (activities.length === 0) {
    return (
      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>
        <div className="text-center py-8">
          <CalendarIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">No recent activity</h3>
          <p className="mt-1 text-sm text-gray-500">
            Booking activity will appear here as it happens.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white shadow rounded-lg p-6">
      <h3 className="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>
      <div className="space-y-4">
        {activities.map((activity) => (
          <div key={activity.id} className="flex items-start space-x-3">
            <div className="flex-shrink-0 mt-1">
              {getActivityIcon(activity.activityType)}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center space-x-2 mb-1">
                <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getActivityColor(activity.activityType)}`}>
                  {getActivityText(activity.activityType)}
                </span>
                <span className="text-sm text-gray-500">
                  #{activity.confirmationCode}
                </span>
              </div>
              <p className="text-sm text-gray-900">
                <span className="font-medium">{activity.userName}</span> • {activity.courseName}
              </p>
              <p className="text-xs text-gray-500">
                {formatTeeTime(activity.teeTime)} • {activity.playersCount} player{activity.playersCount !== 1 ? 's' : ''}
              </p>
            </div>
            <div className="flex-shrink-0 text-xs text-gray-500">
              {formatDistanceToNow(new Date(activity.occurredAt), { addSuffix: true })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default RecentActivityFeed;