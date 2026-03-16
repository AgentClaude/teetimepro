import { useState, useCallback } from "react";
import { useQuery, useMutation } from "@apollo/client";
import { Card } from "../ui/Card";
import { Switch } from "../ui/Switch";
import { Select } from "../ui/Select";
import { LoadingSpinner } from "../ui/LoadingSpinner";
import { 
  GET_NOTIFICATION_PREFERENCES 
} from "../../graphql/queries";
import { 
  UPDATE_NOTIFICATION_PREFERENCES 
} from "../../graphql/mutations";
import { NotificationPreference } from "../../types";
import { debounce } from "lodash";

interface NotificationSection {
  title: string;
  description: string;
  preferences: {
    email: keyof NotificationPreference;
    sms: keyof NotificationPreference; 
    push: keyof NotificationPreference;
  };
}

const NOTIFICATION_SECTIONS: NotificationSection[] = [
  {
    title: "Booking Confirmations",
    description: "When your tee time is confirmed",
    preferences: {
      email: "emailBookingConfirmation",
      sms: "smsBookingConfirmation", 
      push: "pushBookingConfirmation"
    }
  },
  {
    title: "Booking Cancellations",
    description: "When your tee time is cancelled",
    preferences: {
      email: "emailBookingCancellation",
      sms: "smsBookingCancellation",
      push: "pushBookingCancellation"
    }
  },
  {
    title: "Booking Reminders",
    description: "Reminders about upcoming tee times",
    preferences: {
      email: "emailBookingReminder",
      sms: "smsBookingReminder",
      push: "pushBookingReminder"
    }
  },
  {
    title: "Marketing & Promotions",
    description: "Special offers and course updates",
    preferences: {
      email: "emailMarketing",
      sms: "smsMarketing",
      push: "pushMarketing"
    }
  }
];

const REMINDER_OPTIONS = [
  { value: "1", label: "1 hour before" },
  { value: "2", label: "2 hours before" },
  { value: "4", label: "4 hours before" },
  { value: "12", label: "12 hours before" },
  { value: "24", label: "24 hours before" },
  { value: "48", label: "48 hours before" }
];

export function NotificationPreferencesCard() {
  const [localPreferences, setLocalPreferences] = useState<Partial<NotificationPreference>>({});
  const [isUpdating, setIsUpdating] = useState(false);

  const { data, loading, error } = useQuery(GET_NOTIFICATION_PREFERENCES, {
    onCompleted: (data) => {
      if (data?.notificationPreferences) {
        setLocalPreferences(data.notificationPreferences);
      }
    }
  });

  const [updatePreferences] = useMutation(UPDATE_NOTIFICATION_PREFERENCES, {
    onCompleted: () => {
      setIsUpdating(false);
    },
    onError: () => {
      setIsUpdating(false);
    }
  });

  // Debounced update function to avoid too many API calls
  const debouncedUpdate = useCallback(
    debounce(async (preferences: Partial<NotificationPreference>) => {
      setIsUpdating(true);
      try {
        await updatePreferences({
          variables: {
            ...preferences
          }
        });
      } catch (error) {
        console.error("Failed to update notification preferences:", error);
      }
    }, 1000),
    [updatePreferences]
  );

  const handleToggleChange = useCallback((field: keyof NotificationPreference, value: boolean) => {
    const updatedPreferences = {
      ...localPreferences,
      [field]: value
    };
    setLocalPreferences(updatedPreferences);
    debouncedUpdate(updatedPreferences);
  }, [localPreferences, debouncedUpdate]);

  const handleReminderChange = useCallback((value: string) => {
    const reminderHours = parseInt(value, 10);
    const updatedPreferences = {
      ...localPreferences,
      reminderHoursBefore: reminderHours
    };
    setLocalPreferences(updatedPreferences);
    debouncedUpdate(updatedPreferences);
  }, [localPreferences, debouncedUpdate]);

  if (loading) {
    return (
      <Card className="p-6">
        <div className="flex items-center justify-center py-8">
          <LoadingSpinner size="lg" />
        </div>
      </Card>
    );
  }

  if (error) {
    return (
      <Card className="p-6">
        <div className="text-center py-8">
          <p className="text-red-600">Failed to load notification preferences</p>
          <p className="text-sm text-rough-500 mt-1">{error.message}</p>
        </div>
      </Card>
    );
  }

  const preferences = data?.notificationPreferences || localPreferences;

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h3 className="text-lg font-semibold text-rough-900">
            Notification Preferences
          </h3>
          <p className="text-sm text-rough-500 mt-1">
            Choose how and when you want to receive notifications
          </p>
        </div>
        {isUpdating && (
          <div className="flex items-center text-sm text-rough-500">
            <LoadingSpinner size="sm" className="mr-2" />
            Saving...
          </div>
        )}
      </div>

      <div className="space-y-8">
        {NOTIFICATION_SECTIONS.map((section) => (
          <div key={section.title}>
            <div className="mb-4">
              <h4 className="font-medium text-rough-900">{section.title}</h4>
              <p className="text-sm text-rough-500">{section.description}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="flex items-center justify-between p-3 bg-rough-50 rounded-lg dark:bg-gray-800">
                <div className="flex items-center space-x-3">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-rough-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-rough-900 dark:text-white">Email</p>
                  </div>
                </div>
                <Switch
                  checked={Boolean(preferences[section.preferences.email])}
                  onCheckedChange={(checked) => handleToggleChange(section.preferences.email, checked)}
                  size="sm"
                />
              </div>

              <div className="flex items-center justify-between p-3 bg-rough-50 rounded-lg dark:bg-gray-800">
                <div className="flex items-center space-x-3">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-rough-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-rough-900 dark:text-white">SMS</p>
                  </div>
                </div>
                <Switch
                  checked={Boolean(preferences[section.preferences.sms])}
                  onCheckedChange={(checked) => handleToggleChange(section.preferences.sms, checked)}
                  size="sm"
                />
              </div>

              <div className="flex items-center justify-between p-3 bg-rough-50 rounded-lg dark:bg-gray-800">
                <div className="flex items-center space-x-3">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-rough-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-5 5v-5zM12 7a4 4 0 018 0v10a4 4 0 01-8 0V7zM4 7a4 4 0 018 0v10a4 4 0 01-8 0V7z" />
                    </svg>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-rough-900 dark:text-white">Push</p>
                  </div>
                </div>
                <Switch
                  checked={Boolean(preferences[section.preferences.push])}
                  onCheckedChange={(checked) => handleToggleChange(section.preferences.push, checked)}
                  size="sm"
                />
              </div>
            </div>
          </div>
        ))}

        {/* Reminder Timing Section */}
        <div className="pt-6 border-t border-rough-200 dark:border-gray-700">
          <div className="mb-4">
            <h4 className="font-medium text-rough-900 dark:text-white">Reminder Timing</h4>
            <p className="text-sm text-rough-500">When should we send booking reminders?</p>
          </div>

          <div className="max-w-xs">
            <Select
              value={preferences.reminderHoursBefore?.toString() || "24"}
              onChange={handleReminderChange}
              options={REMINDER_OPTIONS}
              label="Send reminders"
            />
          </div>
        </div>
      </div>
    </Card>
  );
}