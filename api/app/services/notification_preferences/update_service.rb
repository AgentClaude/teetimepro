class NotificationPreferences::UpdateService < ApplicationService
  attr_accessor :user, :preferences

  validates :user, presence: true

  def call
    return validation_failure(self) unless valid?

    # Find or initialize notification preference for the user
    notification_preference = NotificationPreference.find_or_initialize_by(user: user)
    
    # Filter out any nil values and assign attributes
    clean_preferences = preferences.compact
    notification_preference.assign_attributes(clean_preferences)

    if notification_preference.save
      success(notification_preference: notification_preference)
    else
      validation_failure(notification_preference)
    end
  end
end