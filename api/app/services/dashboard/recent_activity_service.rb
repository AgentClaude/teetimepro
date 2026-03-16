module Dashboard
  class RecentActivityService < ApplicationService
    attr_accessor :organization, :course_id, :limit

    validates :organization, presence: true
    validates :limit, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

    def initialize(organization:, course_id: nil, limit: 20)
      @organization = organization
      @course_id = course_id
      @limit = limit
    end

    def call
      return validation_failure(self) unless valid?

      success(activities: fetch_activities)
    rescue StandardError => e
      Rails.logger.error("Dashboard recent activity error: #{e.message}")
      failure(["Failed to fetch recent activity: #{e.message}"])
    end

    private

    def fetch_activities
      booking_scope.includes(:user, tee_time: { tee_sheet: :course })
                   .where('bookings.updated_at >= ?', 24.hours.ago)
                   .order('bookings.updated_at DESC')
                   .limit(limit)
                   .map do |booking|
                     {
                       id: booking.id,
                       activity_type: determine_activity_type(booking),
                       confirmation_code: booking.confirmation_code,
                       user_name: booking.user.full_name,
                       course_name: booking.course.name,
                       tee_time: booking.starts_at,
                       players_count: booking.players_count,
                       occurred_at: booking.updated_at
                     }
                   end
    end

    def booking_scope
      scope = Booking.for_organization(organization)
      if course_id.present?
        scope = scope.joins(tee_time: { tee_sheet: :course }).where(courses: { id: course_id })
      end
      scope
    end

    def determine_activity_type(booking)
      case booking.status
      when 'confirmed'
        'booked'
      when 'cancelled'
        'cancelled'
      when 'checked_in'
        'checked_in'
      when 'completed'
        'completed'
      when 'no_show'
        'no_show'
      else
        'booked'
      end
    end
  end
end