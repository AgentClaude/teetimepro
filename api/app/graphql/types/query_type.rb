module Types
  class QueryType < Types::BaseObject
    # Current user
    field :me, Types::UserType, null: true
    def me
      context[:current_user]
    end

    # Single course
    field :course, Types::CourseType, null: true do
      argument :id, ID, required: true
    end
    def course(id:)
      org = require_auth!
      org.courses.find(id)
    end

    # All courses for current org
    field :courses, [Types::CourseType], null: false
    def courses
      org = require_auth!
      org.courses.order(:name)
    end

    # Tee sheet for a course on a date
    field :tee_sheet, Types::TeeSheetType, null: true do
      argument :course_id, ID, required: true
      argument :date, GraphQL::Types::ISO8601Date, required: true
    end
    def tee_sheet(course_id:, date:)
      org = require_auth!
      course = org.courses.find(course_id)
      course.tee_sheets.find_by(date: date)
    end

    # Single booking
    field :booking, Types::BookingType, null: true do
      argument :id, ID, required: true
    end
    def booking(id:)
      require_auth!
      user = context[:current_user]
      if user.can_manage_bookings?
        Booking.for_organization(user.organization).find(id)
      else
        user.bookings.find(id)
      end
    end

    # Bookings list (filtered)
    field :bookings, [Types::BookingType], null: false do
      argument :date, GraphQL::Types::ISO8601Date, required: false
      argument :status, String, required: false
    end
    def bookings(date: nil, status: nil)
      require_auth!
      user = context[:current_user]
      scope = if user.can_manage_bookings?
                Booking.for_organization(user.organization)
              else
                user.bookings
              end

      scope = scope.for_date(date) if date
      scope = scope.where(status: status) if status
      scope.includes(tee_time: { tee_sheet: :course }).order("tee_times.starts_at DESC")
    end

    # SMS Campaigns
    field :sms_campaigns, [Types::SmsCampaignType], null: false do
      argument :status, String, required: false
    end
    def sms_campaigns(status: nil)
      org = require_auth!
      scope = org.sms_campaigns.order(created_at: :desc)
      scope = scope.where(status: status) if status.present?
      scope.limit(50)
    end

    field :sms_campaign, Types::SmsCampaignType, null: true do
      argument :id, ID, required: true
    end
    def sms_campaign(id:)
      org = require_auth!
      org.sms_campaigns.find(id)
    end

    # Voice call logs
    field :voice_call_logs, [Types::VoiceCallLogType], null: false do
      argument :course_id, ID, required: false
      argument :channel, String, required: false
      argument :limit, Integer, required: false
    end
    def voice_call_logs(course_id: nil, channel: nil, limit: 50)
      org = require_auth!
      scope = VoiceCallLog.for_organization(org).recent
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(channel: channel) if channel.present?
      scope.includes(:course).limit([limit, 100].min)
    end

    field :voice_call_log, Types::VoiceCallLogType, null: true do
      argument :id, ID, required: true
    end
    def voice_call_log(id:)
      org = require_auth!
      VoiceCallLog.for_organization(org).find(id)
    end

    # Available tee times
    field :available_tee_times, [Types::TeeTimeType], null: false do
      argument :course_id, ID, required: true
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :players, Integer, required: false
    end
    def available_tee_times(course_id:, date:, players: 1)
      org = require_auth!
      course = org.courses.find(course_id)
      tee_sheet = course.tee_sheets.find_by(date: date)
      return [] unless tee_sheet

      tee_sheet.tee_times.available_for(players).order(:starts_at)
    end
  end
end
