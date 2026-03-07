module Types
  class QueryType < Types::BaseObject
    # Current user
    field :me, Types::UserType, null: true
    def me
      context[:current_user]
    end

    # Dashboard stats
    field :dashboard_stats, Types::DashboardStatsType, null: false do
      argument :course_id, ID, required: false
      argument :date, GraphQL::Types::ISO8601Date, required: false
    end
    def dashboard_stats(course_id: nil, date: nil)
      org = require_auth!
      result = Dashboard::StatsService.call(
        organization: org,
        course_id: course_id,
        date: date
      )
      
      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
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
      argument :course_id, ID, required: false
      argument :date, GraphQL::Types::ISO8601Date, required: false
      argument :status, String, required: false
    end
    def bookings(course_id: nil, date: nil, status: nil)
      require_auth!
      user = context[:current_user]
      scope = if user.can_manage_bookings?
                Booking.for_organization(user.organization)
              else
                user.bookings
              end

      if course_id.present?
        scope = scope.joins(tee_time: { tee_sheet: :course }).where(courses: { id: course_id })
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

    # Customers (users in the org)
    field :customers, [Types::UserType], null: false do
      argument :search, String, required: false
      argument :role, String, required: false
    end
    def customers(search: nil, role: nil)
      org = require_auth!
      scope = org.users.order(created_at: :desc)
      scope = scope.where(role: role) if role.present?
      if search.present?
        term = "%#{search}%"
        scope = scope.where(
          "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR phone ILIKE :q",
          q: term
        )
      end
      scope.limit(100)
    end

    field :customer, Types::UserType, null: true do
      argument :id, ID, required: true
    end
    def customer(id:)
      org = require_auth!
      org.users.find(id)
    end

    # Tournaments
    field :tournaments, [Types::TournamentType], null: false do
      argument :course_id, ID, required: false
      argument :status, Types::TournamentStatusEnum, required: false
      argument :upcoming_only, Boolean, required: false
    end
    def tournaments(course_id: nil, status: nil, upcoming_only: nil)
      org = require_auth!
      scope = org.tournaments.includes(:course, :created_by)
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(status: status) if status.present?
      scope = scope.upcoming if upcoming_only
      scope.order(start_date: :asc)
    end

    field :tournament, Types::TournamentType, null: true do
      argument :id, ID, required: true
    end
    def tournament(id:)
      org = require_auth!
      org.tournaments.includes(:tournament_entries, :course, :created_by).find(id)
    end

    # Reports summary
    field :reports_summary, GraphQL::Types::JSON, null: false do
      argument :course_id, ID, required: false
      argument :days, Integer, required: false
    end
    def reports_summary(course_id: nil, days: 30)
      org = require_auth!
      days = [days, 90].min

      bookings_scope = Booking.for_organization(org)
      if course_id.present?
        bookings_scope = bookings_scope.joins(tee_time: { tee_sheet: :course }).where(courses: { id: course_id })
      end

      today = Date.current
      period_start = today - days.days

      recent = bookings_scope.where("bookings.created_at >= ?", period_start.beginning_of_day)
      today_bookings = bookings_scope.joins(tee_time: :tee_sheet).where(tee_sheets: { date: today })

      # Daily booking counts for chart
      daily = recent.group("DATE(bookings.created_at)").count.transform_keys(&:to_s)
      daily_revenue = recent.where(status: :confirmed).group("DATE(bookings.created_at)").sum(:total_cents).transform_keys(&:to_s)

      # Fill in missing days
      chart_data = (0...days).map do |i|
        d = (period_start + i.days).to_s
        { date: d, bookings: daily[d] || 0, revenue: daily_revenue[d] || 0 }
      end

      # Status breakdown
      status_counts = recent.group(:status).count

      {
        today_bookings: today_bookings.where.not(status: :cancelled).count,
        today_revenue: today_bookings.where(status: :confirmed).sum(:total_cents),
        total_bookings: recent.count,
        total_revenue: recent.where(status: :confirmed).sum(:total_cents),
        total_customers: org.users.where(role: :golfer).count,
        cancellation_rate: recent.count > 0 ? (recent.where(status: :cancelled).count.to_f / recent.count * 100).round(1) : 0,
        status_breakdown: status_counts,
        daily: chart_data
      }
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

    # Accounting integration
    field :accounting_integration, Types::AccountingIntegrationType, null: true do
      argument :provider, Types::AccountingProviderEnum, required: true
    end
    def accounting_integration(provider:)
      org = require_auth!
      require_role!(:manager)
      
      org.accounting_integrations.find_by(provider: provider)
    end

    # Accounting sync history
    field :accounting_sync_history, [Types::AccountingSyncType], null: false do
      argument :provider, Types::AccountingProviderEnum, required: false
      argument :sync_type, Types::AccountingSyncTypeEnum, required: false
      argument :status, Types::AccountingSyncStatusEnum, required: false
      argument :limit, Integer, required: false
    end
    def accounting_sync_history(provider: nil, sync_type: nil, status: nil, limit: 50)
      org = require_auth!
      require_role!(:manager)

      syncs = AccountingSync.joins(:accounting_integration)
                           .where(accounting_integrations: { organization_id: org.id })

      syncs = syncs.joins(:accounting_integration).where(accounting_integrations: { provider: provider }) if provider
      syncs = syncs.where(sync_type: sync_type) if sync_type
      syncs = syncs.where(status: status) if status

      syncs.recent.limit([limit, 100].min)
    end
  end
end
