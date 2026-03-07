module Types
  class QueryType < Types::BaseObject
    # Public queries (no auth required)
    field :public_course, Types::CourseType, null: true do
      argument :slug, String, required: true
    end
    def public_course(slug:)
      Course.joins(:organization).find_by(slug: slug)
    end

    field :public_available_tee_times, [Types::TeeTimeType], null: false do
      argument :course_slug, String, required: true
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :players, Integer, required: false
      argument :time_preference, String, required: false # morning, afternoon, twilight
    end
    def public_available_tee_times(course_slug:, date:, players: 1, time_preference: nil)
      course = Course.joins(:organization).find_by!(slug: course_slug)

      result = Bookings::SearchAvailabilityService.call(
        organization: course.organization,
        course_id: course.id,
        date: date,
        players: players,
        time_preference: time_preference,
        include_pricing: true
      )

      return [] unless result.success?

      tee_time_ids = result.data[:slots].map { |s| s[:tee_time_id] }
      TeeTime.where(id: tee_time_ids).order(:starts_at)
    end

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

    # Email Campaigns
    field :email_campaigns, [Types::EmailCampaignType], null: false do
      argument :status, String, required: false
    end
    def email_campaigns(status: nil)
      org = require_auth!
      scope = org.email_campaigns.order(created_at: :desc)
      scope = scope.where(status: status) if status.present?
      scope.limit(50)
    end

    field :email_campaign, Types::EmailCampaignType, null: true do
      argument :id, ID, required: true
    end
    def email_campaign(id:)
      org = require_auth!
      org.email_campaigns.find(id)
    end

    # Email Providers
    field :email_providers, [Types::EmailProviderType], null: false
    def email_providers
      org = require_auth!
      org.email_providers.order(created_at: :desc)
    end

    # Email Templates
    field :email_templates, [Types::EmailTemplateType], null: false do
      argument :category, String, required: false
    end
    def email_templates(category: nil)
      org = require_auth!
      scope = org.email_templates.active.order(created_at: :desc)
      scope = scope.by_category(category) if category.present?
      scope.limit(50)
    end

    field :email_template, Types::EmailTemplateType, null: true do
      argument :id, ID, required: true
    end
    def email_template(id:)
      org = require_auth!
      org.email_templates.find(id)
    end

    # Booking email templates (transactional)
    field :booking_email_templates, [Types::EmailTemplateType], null: false
    def booking_email_templates
      org = require_auth!
      org.email_templates.active.by_category("transactional").order(name: :asc)
    end

    # Voice analytics
    field :voice_analytics, Types::VoiceAnalyticsType, null: false do
      argument :course_id, ID, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: true
      argument :end_date, GraphQL::Types::ISO8601Date, required: true
    end
    def voice_analytics(course_id: nil, start_date:, end_date:)
      org = require_auth!
      result = Voice::AnalyticsService.call(
        organization: org,
        course_id: course_id,
        start_date: start_date,
        end_date: end_date
      )
      
      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
    end

    # Voice call logs
    field :voice_call_logs, [Types::VoiceCallLogType], null: false do
      argument :course_id, ID, required: false
      argument :channel, String, required: false
      argument :status, String, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :limit, Integer, required: false
      argument :offset, Integer, required: false
    end
    def voice_call_logs(course_id: nil, channel: nil, status: nil, start_date: nil, end_date: nil, limit: 50, offset: 0)
      org = require_auth!
      scope = VoiceCallLog.for_organization(org).recent
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(channel: channel) if channel.present?
      scope = scope.where(status: status) if status.present?
      
      if start_date.present? && end_date.present?
        scope = scope.where(started_at: start_date.beginning_of_day..end_date.end_of_day)
      end
      
      scope.includes(:course).limit([limit, 100].min).offset(offset)
    end

    field :voice_call_log, Types::VoiceCallLogType, null: true do
      argument :id, ID, required: true
    end
    def voice_call_log(id:)
      org = require_auth!
      VoiceCallLog.for_organization(org).find(id)
    end

    # Voice handoffs
    field :voice_handoffs, [Types::VoiceHandoffType], null: false do
      argument :status, Types::VoiceHandoffStatusEnum, required: false
      argument :reason, Types::VoiceHandoffReasonEnum, required: false
      argument :active_only, Boolean, required: false, default_value: false
      argument :limit, Integer, required: false
      argument :offset, Integer, required: false
    end
    def voice_handoffs(status: nil, reason: nil, active_only: false, limit: 50, offset: 0)
      org = require_auth!
      scope = VoiceHandoff.for_organization(org).order(started_at: :desc)
      scope = scope.where(status: status) if status.present?
      scope = scope.where(reason: reason) if reason.present?
      scope = scope.active if active_only
      scope.includes(:voice_call_log).limit([limit, 100].min).offset(offset)
    end

    field :voice_handoff, Types::VoiceHandoffType, null: true do
      argument :id, ID, required: true
    end
    def voice_handoff(id:)
      org = require_auth!
      VoiceHandoff.for_organization(org).includes(:voice_call_log).find(id)
    end

    # Customers (users in the org)
    field :customers, Types::CustomerConnectionType, null: false, connection: false do
      argument :search, String, required: false
      argument :role, String, required: false
      argument :membership_tier, String, required: false, description: "Filter by membership tier (basic, silver, gold, platinum, none)"
      argument :loyalty_tier, String, required: false, description: "Filter by loyalty tier (bronze, silver, gold, platinum, none)"
      argument :min_bookings, Integer, required: false, description: "Minimum number of bookings"
      argument :max_bookings, Integer, required: false, description: "Maximum number of bookings"
      argument :sort_by, String, required: false, description: "Sort field (name, email, bookings_count, created_at)"
      argument :sort_dir, String, required: false, description: "Sort direction (asc, desc)"
      argument :page, Integer, required: false, description: "Page number (1-based)"
      argument :per_page, Integer, required: false, description: "Items per page (max 100)"
    end
    def customers(search: nil, role: nil, membership_tier: nil, loyalty_tier: nil, min_bookings: nil, max_bookings: nil, sort_by: nil, sort_dir: nil, page: nil, per_page: nil)
      org = require_auth!
      scope = org.users

      # Text search
      if search.present?
        term = "%#{search}%"
        scope = scope.where(
          "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR phone ILIKE :q",
          q: term
        )
      end

      # Role filter
      scope = scope.where(role: role) if role.present?

      # Membership tier filter
      if membership_tier.present?
        if membership_tier == "none"
          scope = scope.where.not(
            id: org.memberships.active.select(:user_id)
          )
        else
          scope = scope.where(
            id: org.memberships.active.where(tier: membership_tier).select(:user_id)
          )
        end
      end

      # Loyalty tier filter
      if loyalty_tier.present?
        if loyalty_tier == "none"
          scope = scope.where.not(
            id: LoyaltyAccount.where(organization: org).select(:user_id)
          )
        else
          scope = scope.where(
            id: LoyaltyAccount.where(organization: org, tier: loyalty_tier).select(:user_id)
          )
        end
      end

      # Bookings count filter
      if min_bookings.present? || max_bookings.present?
        scope = scope.left_joins(:bookings)
          .group("users.id")
        scope = scope.having("COUNT(bookings.id) >= ?", min_bookings) if min_bookings.present?
        scope = scope.having("COUNT(bookings.id) <= ?", max_bookings) if max_bookings.present?
      end

      # Sorting
      sort_field = case sort_by
                   when "name" then "last_name"
                   when "email" then "email"
                   when "bookings_count" then nil # handled separately
                   when "created_at" then "created_at"
                   else "created_at"
                   end
      direction = sort_dir == "asc" ? :asc : :desc

      if sort_by == "bookings_count"
        scope = scope.left_joins(:bookings).group("users.id") unless min_bookings.present? || max_bookings.present?
        scope = scope.order(Arel.sql("COUNT(bookings.id) #{direction}"))
      else
        scope = scope.order(sort_field => direction)
      end

      # Pagination
      page = [page.to_i, 1].max
      per_page = per_page.present? ? [[per_page.to_i, 1].max, 100].min : 25

      # For grouped queries, .count returns a hash; use .size to get integer count
      count_result = scope.count
      total_count = count_result.is_a?(Hash) ? count_result.keys.length : count_result
      offset = (page - 1) * per_page

      nodes = scope.offset(offset).limit(per_page)

      {
        nodes: nodes,
        total_count: total_count,
        page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil
      }
    end

    field :customer, Types::UserType, null: true do
      argument :id, ID, required: true
    end
    def customer(id:)
      org = require_auth!
      org.users.find(id)
    end

    # Golfer Segments
    field :golfer_segments, [Types::GolferSegmentType], null: false
    def golfer_segments
      org = require_auth!
      require_role!(:manager)
      org.golfer_segments.order(created_at: :desc)
    end

    field :golfer_segment, Types::GolferSegmentType, null: true do
      argument :id, ID, required: true
    end
    def golfer_segment(id:)
      org = require_auth!
      require_role!(:manager)
      org.golfer_segments.find(id)
    end

    field :golfer_segment_preview, GraphQL::Types::JSON, null: false do
      argument :filter_criteria, GraphQL::Types::JSON, required: true
    end
    def golfer_segment_preview(filter_criteria:)
      org = require_auth!
      require_role!(:manager)

      result = Segments::EvaluateService.call(
        organization: org,
        filter_criteria: filter_criteria
      )

      if result.success?
        { count: result.count, sample: result.users.limit(5).map { |u| { id: u.id, name: u.full_name, email: u.email } } }
      else
        { count: 0, sample: [], error: result.error_message }
      end
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
      org.tournaments.includes(:tournament_entries, :tournament_rounds, :course, :created_by).find(id)
    end

    # Tournament Leaderboard
    field :tournament_leaderboard, Types::LeaderboardType, null: false do
      description "Get the current leaderboard for a tournament"
      argument :tournament_id, ID, required: true
    end
    def tournament_leaderboard(tournament_id:)
      org = require_auth!
      tournament = org.tournaments.find(tournament_id)

      result = Leaderboard::CalculateService.call(tournament: tournament)

      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
    end

    # Tournament Scorecard for a specific entry
    field :tournament_scorecard, [Types::TournamentScoreType], null: false do
      description "Get hole-by-hole scores for a tournament entry"
      argument :tournament_entry_id, ID, required: true
      argument :round_number, Integer, required: false
    end
    def tournament_scorecard(tournament_entry_id:, round_number: nil)
      org = require_auth!
      entry = TournamentEntry.joins(:tournament).where(tournaments: { organization_id: org.id }).find(tournament_entry_id)

      scope = entry.tournament_scores.includes(:tournament_round).by_hole
      if round_number
        round = entry.tournament.tournament_rounds.find_by!(round_number: round_number)
        scope = scope.for_round(round)
      end
      scope
    end

    # Tournament Results
    field :tournament_results, [Types::TournamentResultType], null: false do
      description "Get finalized results for a tournament"
      argument :tournament_id, ID, required: true
    end
    def tournament_results(tournament_id:)
      org = require_auth!
      tournament = org.tournaments.find(tournament_id)
      tournament.tournament_results.includes(:tournament_entry, :user).by_position
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

    # Available tee times (legacy — kept for backward compat, delegates to service)
    field :available_tee_times, [Types::TeeTimeType], null: false do
      argument :course_id, ID, required: true
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :players, Integer, required: false
    end
    def available_tee_times(course_id:, date:, players: 1)
      org = require_auth!
      result = Bookings::SearchAvailabilityService.call(
        organization: org,
        course_id: course_id,
        date: date,
        players: players,
        include_pricing: false
      )

      return [] unless result.success?

      # Return raw tee time records for backward compat
      tee_time_ids = result.data[:slots].map { |s| s[:tee_time_id] }
      TeeTime.where(id: tee_time_ids).order(:starts_at)
    end

    # Availability search — full-featured slot search with pricing
    field :check_availability, Types::AvailabilitySearchResultType, null: false do
      description "Search available tee time slots across dates with pricing"
      argument :course_id, ID, required: false, description: "Filter to specific course"
      argument :date, GraphQL::Types::ISO8601Date, required: true
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: "End of date range (default: same as date)"
      argument :players, Integer, required: false, default_value: 1, description: "Number of players (1-5)"
      argument :time_preference, String, required: false, description: "morning, afternoon, or twilight"
      argument :include_pricing, Boolean, required: false, default_value: true
    end
    def check_availability(course_id: nil, date:, end_date: nil, players: 1, time_preference: nil, include_pricing: true)
      org = require_auth!

      result = Bookings::SearchAvailabilityService.call(
        organization: org,
        course_id: course_id,
        date: date,
        end_date: end_date,
        players: players,
        time_preference: time_preference,
        include_pricing: include_pricing
      )

      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
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

      syncs = syncs.where(accounting_integrations: { provider: provider }) if provider
      syncs = syncs.where(sync_type: sync_type) if sync_type
      syncs = syncs.where(status: status) if status

      syncs.recent.limit([limit, 100].min)
    end

    # F&B Tabs - List all tabs
    field :fnb_tabs, [Types::FnbTabType], null: false do
      argument :status, Types::FnbTabStatusEnum, required: false
      argument :course_id, ID, required: false
      argument :limit, Integer, required: false
    end
    def fnb_tabs(status: nil, course_id: nil, limit: 50)
      org = require_auth!
      
      tabs = org.fnb_tabs.includes(:course, :user, :fnb_tab_items)
      tabs = tabs.where(status: status.downcase) if status
      tabs = tabs.where(course_id: course_id) if course_id
      
      tabs.recent.limit([limit, 100].min)
    end

    # F&B Tabs - Single tab
    field :fnb_tab, Types::FnbTabType, null: true do
      argument :id, ID, required: true
    end
    def fnb_tab(id:)
      org = require_auth!
      org.fnb_tabs.includes(:course, :user, :fnb_tab_items).find_by(id: id)
    end

    # Member accounts
    field :member_account_charges, [Types::MemberAccountChargeType], null: false do
      argument :membership_id, ID, required: false
      argument :charge_type, String, required: false
      argument :status, String, required: false
      argument :limit, Integer, required: false
    end
    def member_account_charges(membership_id: nil, charge_type: nil, status: nil, limit: 50)
      org = require_auth!

      scope = org.member_account_charges.includes(:membership, :charged_by).recent
      scope = scope.where(membership_id: membership_id) if membership_id.present?
      scope = scope.where(charge_type: charge_type) if charge_type.present?
      scope = scope.where(status: status) if status.present?
      scope.limit([limit, 100].min)
    end

    field :member_account_statement, Types::MemberAccountStatementType, null: true do
      argument :membership_id, ID, required: true
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :page, Integer, required: false
      argument :per_page, Integer, required: false
    end
    def member_account_statement(membership_id:, start_date: nil, end_date: nil, page: nil, per_page: nil)
      org = require_auth!

      result = MemberAccounts::ViewStatementService.call(
        organization: org,
        user: context[:current_user],
        membership_id: membership_id,
        start_date: start_date,
        end_date: end_date,
        page: page,
        per_page: per_page
      )

      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
    end

    field :memberships, [Types::MembershipType], null: false do
      argument :status, String, required: false
      argument :tier, String, required: false
      argument :with_balance, Boolean, required: false
    end
    def memberships(status: nil, tier: nil, with_balance: nil)
      org = require_auth!

      scope = org.memberships.includes(:user).order(created_at: :desc)
      scope = scope.where(status: status) if status.present?
      scope = scope.where(tier: tier) if tier.present?
      scope = scope.with_balance if with_balance
      scope.limit(100)
    end

    field :membership, Types::MembershipType, null: true do
      argument :id, ID, required: true
    end
    def membership(id:)
      org = require_auth!
      org.memberships.includes(:user, :member_account_charges).find(id)
    end

    # POS Products
    field :pos_products, [Types::PosProductType], null: false do
      argument :category, String, required: false
      argument :search, String, required: false
      argument :active_only, Boolean, required: false, default_value: true
    end
    def pos_products(category: nil, search: nil, active_only: true)
      org = require_auth!
      scope = org.pos_products.order(:category, :name)
      scope = scope.active if active_only
      scope = scope.by_category(category) if category.present?
      scope = scope.search(search) if search.present?
      scope
    end

    field :pos_product, Types::PosProductType, null: true do
      argument :id, ID, required: true
    end
    def pos_product(id:)
      org = require_auth!
      org.pos_products.find_by(id: id)
    end

    # Low Stock Products
    field :low_stock_products, [Types::InventoryLevelType], null: false do
      argument :course_id, ID, required: false
      argument :category, String, required: false
    end
    def low_stock_products(course_id: nil, category: nil)
      org = require_auth!
      course = course_id ? org.courses.find(course_id) : nil
      
      result = Inventory::CheckLowStockService.call(
        organization: org,
        course: course,
        category: category
      )

      if result.success?
        result.low_stock_items
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
    end

    # Inventory Movements
    field :inventory_movements, [Types::InventoryMovementType], null: false do
      argument :product_id, ID, required: false
      argument :course_id, ID, required: false
      argument :movement_type, String, required: false
      argument :limit, Integer, required: false, default_value: 50
      argument :offset, Integer, required: false, default_value: 0
    end
    def inventory_movements(product_id: nil, course_id: nil, movement_type: nil, limit: 50, offset: 0)
      org = require_auth!
      
      scope = InventoryMovement.for_organization(org).includes(:pos_product, :course, :performed_by).recent
      scope = scope.for_product(org.pos_products.find(product_id)) if product_id.present?
      scope = scope.for_course(org.courses.find(course_id)) if course_id.present?
      scope = scope.where(movement_type: movement_type) if movement_type.present?
      
      scope.limit([limit, 100].min).offset(offset)
    end

    # Inventory Levels
    field :inventory_levels, [Types::InventoryLevelType], null: false do
      argument :course_id, ID, required: false
      argument :product_id, ID, required: false
      argument :low_stock_only, Boolean, required: false, default_value: false
    end
    def inventory_levels(course_id: nil, product_id: nil, low_stock_only: false)
      org = require_auth!
      
      scope = InventoryLevel.for_organization(org).includes(:pos_product, :course)
      scope = scope.for_course(org.courses.find(course_id)) if course_id.present?
      scope = scope.where(pos_product_id: product_id) if product_id.present?
      scope = scope.low_stock if low_stock_only
      
      scope.joins(:pos_product).order('pos_products.name')
    end

    # Turn orders
    field :turn_orders, [Types::FnbTabType], null: false do
      argument :date, GraphQL::Types::ISO8601Date, required: false,
               description: 'Filter by tee sheet date (defaults to today)'
      argument :status, String, required: false, default_value: 'open'
    end
    def turn_orders(date: nil, status: 'open')
      org = require_auth!
      target_date = date || Date.current

      scope = org.fnb_tabs.turn_orders
                 .joins(booking: { tee_time: :tee_sheet })
                 .where(tee_sheets: { date: target_date })
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc)
    end

    # Pricing rules
    field :pricing_rules, [Types::PricingRuleType], null: false do
      argument :course_id, ID, required: false
      argument :rule_type, Types::PricingRuleTypeEnum, required: false
      argument :active, Boolean, required: false
    end
    def pricing_rules(course_id: nil, rule_type: nil, active: nil)
      org = require_auth!
      require_role!(:manager)

      scope = org.pricing_rules.includes(:course).by_priority
      scope = scope.for_course(course_id) if course_id.present?
      scope = scope.where(rule_type: rule_type) if rule_type.present?
      scope = scope.where(active: active) unless active.nil?
      scope
    end

    field :pricing_rule, Types::PricingRuleType, null: true do
      argument :id, ID, required: true
    end
    def pricing_rule(id:)
      org = require_auth!
      require_role!(:manager)
      org.pricing_rules.includes(:course).find(id)
    end

    # Utilization heat map
    field :utilization_heat_map, Types::UtilizationHeatMapType, null: false do
      argument :course_id, ID, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: true
      argument :end_date, GraphQL::Types::ISO8601Date, required: true
    end
    def utilization_heat_map(course_id: nil, start_date:, end_date:)
      org = require_auth!
      require_role!(:manager)

      result = Dashboard::UtilizationHeatMapService.call(
        organization: org,
        course_id: course_id,
        start_date: start_date,
        end_date: end_date
      )

      if result.success?
        result.data
      else
        raise GraphQL::ExecutionError, result.errors.join(", ")
      end
    end

    # Marketplace connections
    field :marketplace_connections, [Types::MarketplaceConnectionType], null: false do
      argument :course_id, ID, required: false
      argument :provider, Types::MarketplaceProviderEnum, required: false
      argument :status, Types::MarketplaceConnectionStatusEnum, required: false
    end
    def marketplace_connections(course_id: nil, provider: nil, status: nil)
      org = require_auth!
      require_role!(:manager)

      scope = org.marketplace_connections.includes(:course, :marketplace_listings)
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(provider: provider) if provider.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc)
    end

    field :marketplace_connection, Types::MarketplaceConnectionType, null: true do
      argument :id, ID, required: true
    end
    def marketplace_connection(id:)
      org = require_auth!
      require_role!(:manager)
      org.marketplace_connections.includes(:course, :marketplace_listings).find(id)
    end

    # Marketplace listings
    field :marketplace_listings, [Types::MarketplaceListingType], null: false do
      argument :connection_id, ID, required: false
      argument :status, Types::MarketplaceListingStatusEnum, required: false
      argument :limit, Integer, required: false
    end
    def marketplace_listings(connection_id: nil, status: nil, limit: 50)
      org = require_auth!
      require_role!(:manager)

      scope = MarketplaceListing.joins(:marketplace_connection)
                                .where(marketplace_connections: { organization_id: org.id })
                                .includes(:tee_time, :marketplace_connection)

      scope = scope.where(marketplace_connection_id: connection_id) if connection_id.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc).limit([limit, 100].min)
    end

    # Call recordings
    field :call_recordings, [Types::CallRecordingType], null: false do
      argument :status, String, required: false
      argument :date_from, GraphQL::Types::ISO8601Date, required: false
      argument :date_to, GraphQL::Types::ISO8601Date, required: false
      argument :query, String, required: false, description: "Search in transcription text"
      argument :page, Integer, required: false, default_value: 1
      argument :per_page, Integer, required: false, default_value: 20
    end
    def call_recordings(status: nil, date_from: nil, date_to: nil, query: nil, page: 1, per_page: 20)
      org = require_auth!
      
      filters = {}
      filters[:status] = status if status.present?
      filters[:date_from] = date_from if date_from.present?
      filters[:date_to] = date_to if date_to.present?

      result = Recordings::SearchService.call(
        organization: org,
        query: query,
        filters: filters,
        page: page,
        per_page: per_page
      )

      if result.success?
        result.recordings
      else
        raise GraphQL::ExecutionError, result.error_messages
      end
    end

    field :call_recording, Types::CallRecordingType, null: true do
      argument :id, ID, required: true
    end
    def call_recording(id:)
      org = require_auth!
      CallRecording.for_organization(org).includes(:call_transcriptions, :voice_call_log).find(id)
    end

    # Loyalty Program
    field :loyalty_program, Types::LoyaltyProgramType, null: true
    def loyalty_program
      org = require_auth!
      org.loyalty_programs.active.first
    end

    # Current user's loyalty account
    field :loyalty_account, Types::LoyaltyAccountType, null: true
    def loyalty_account
      require_auth!
      current_user.loyalty_account
    end

    # Loyalty rewards
    field :loyalty_rewards, [Types::LoyaltyRewardType], null: false do
      argument :reward_type, Types::LoyaltyRewardTypeEnum, required: false
      argument :affordable_only, Boolean, required: false
      argument :active_only, Boolean, required: false, default_value: true
    end
    def loyalty_rewards(reward_type: nil, affordable_only: false, active_only: true)
      org = require_auth!
      scope = org.loyalty_rewards.order(:points_cost)
      scope = scope.active if active_only
      scope = scope.by_type(reward_type) if reward_type.present?
      
      if affordable_only && current_user&.loyalty_account
        scope = scope.affordable_for(current_user.loyalty_account.points_balance)
      end
      
      scope
    end

    # Loyalty transactions
    field :loyalty_transactions, [Types::LoyaltyTransactionType], null: false do
      argument :user_id, ID, required: false
      argument :transaction_type, String, required: false
      argument :limit, Integer, required: false, default_value: 50
    end
    def loyalty_transactions(user_id: nil, transaction_type: nil, limit: 50)
      org = require_auth!
      
      if user_id.present?
        # Manager can view other users' transactions
        require_role!(:manager)
        account = org.loyalty_accounts.where(user_id: user_id).first
        return [] unless account
      else
        # Regular users see their own transactions
        account = current_user.loyalty_account
        return [] unless account
      end
      
      scope = account.loyalty_transactions.recent.includes(:source)
      scope = scope.by_type(transaction_type) if transaction_type.present?
      scope.limit([limit, 100].min)
    end

    # Loyalty redemptions (admin view)
    field :loyalty_redemptions, [Types::LoyaltyRedemptionType], null: false do
      argument :status, String, required: false
      argument :reward_id, ID, required: false
      argument :user_id, ID, required: false
      argument :limit, Integer, required: false, default_value: 50
    end
    def loyalty_redemptions(status: nil, reward_id: nil, user_id: nil, limit: 50)
      org = require_auth!
      require_role!(:staff) # Staff and above can view redemptions
      
      scope = LoyaltyRedemption.joins(:loyalty_account)
                               .where(loyalty_accounts: { organization_id: org.id })
                               .includes(:loyalty_account, :loyalty_reward, :booking)
                               .order(created_at: :desc)
      
      scope = scope.where(status: status) if status.present?
      scope = scope.where(loyalty_reward_id: reward_id) if reward_id.present?
      scope = scope.where(loyalty_accounts: { user_id: user_id }) if user_id.present?
      scope.limit([limit, 100].min)
    end
  end
end
