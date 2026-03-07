module Dashboard
  class StatsService < ApplicationService
    attr_accessor :organization, :course_id, :date

    validates :organization, presence: true

    def initialize(organization:, course_id: nil, date: nil)
      @organization = organization
      @course_id = course_id
      @date = date || Date.current
    end

    def call
      return validation_failure(self) unless valid?

      success(
        todays_bookings: todays_bookings_count,
        todays_revenue_cents: todays_revenue_cents,
        active_members: active_members_count,
        utilization_percentage: utilization_percentage,
        upcoming_bookings: upcoming_bookings_data,
        weekly_revenue: weekly_revenue_data
      )
    rescue StandardError => e
      Rails.logger.error("Dashboard stats error: #{e.message}")
      failure(["Failed to generate dashboard stats: #{e.message}"])
    end

    private

    def booking_scope
      scope = Booking.for_organization(organization)
      scope = scope.joins(tee_time: { tee_sheet: :course }).where(courses: { id: course_id }) if course_id.present?
      scope
    end

    def todays_bookings_count
      booking_scope.for_date(date)
                  .where(status: [:confirmed, :checked_in, :completed])
                  .count
    end

    def todays_revenue_cents
      booking_scope.for_date(date)
                  .where(status: [:confirmed, :checked_in, :completed])
                  .sum(:total_cents) || 0
    end

    def active_members_count
      scope = organization.users.where.not(role: nil)
      scope = scope.joins(bookings: { tee_time: { tee_sheet: :course } })
                  .where(courses: { id: course_id }) if course_id.present?
      scope.distinct.count
    end

    def utilization_percentage
      tee_sheets = if course_id.present?
                     TeeSheet.joins(:course)
                             .where(courses: { organization: organization, id: course_id })
                             .for_date(date)
                   else
                     TeeSheet.joins(:course)
                             .where(courses: { organization: organization })
                             .for_date(date)
                   end

      return 0.0 if tee_sheets.empty?

      total_utilizations = tee_sheets.map(&:utilization_percentage)
      total_utilizations.sum / total_utilizations.count
    end

    def upcoming_bookings_data
      booking_scope.upcoming
                  .includes(:user, tee_time: { tee_sheet: :course })
                  .order('tee_times.starts_at ASC')
                  .limit(5)
                  .map do |booking|
                    {
                      id: booking.id,
                      confirmation_code: booking.confirmation_code,
                      user_name: booking.user.full_name,
                      course_name: booking.course.name,
                      tee_time: booking.starts_at,
                      players_count: booking.players_count,
                      total_cents: booking.total_cents
                    }
                  end
    end

    def weekly_revenue_data
      end_date = date
      start_date = end_date - 6.days
      
      (start_date..end_date).map do |day|
        revenue_cents = booking_scope.for_date(day)
                                    .where(status: [:confirmed, :checked_in, :completed])
                                    .sum(:total_cents) || 0
        
        {
          date: day,
          revenue_cents: revenue_cents
        }
      end
    end
  end
end
