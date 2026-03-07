module Voice
  class AnalyticsService < ApplicationService
    attr_accessor :organization, :course_id, :start_date, :end_date

    validates :organization, presence: true
    validates :start_date, presence: true
    validates :end_date, presence: true

    def initialize(organization:, course_id: nil, start_date:, end_date:)
      @organization = organization
      @course_id = course_id
      @start_date = start_date
      @end_date = end_date
    end

    def call
      return validation_failure(self) unless valid?

      success(
        total_calls: total_calls_count,
        completed_calls: completed_calls_count,
        error_rate: error_rate_percentage,
        average_duration_seconds: average_duration_seconds,
        booking_conversion_rate: booking_conversion_rate_percentage,
        calls_by_channel: calls_by_channel_data,
        calls_by_day: calls_by_day_data,
        top_callers: top_callers_data
      )
    rescue StandardError => e
      Rails.logger.error("Voice analytics error: #{e.message}")
      failure(["Failed to generate voice analytics: #{e.message}"])
    end

    private

    def base_scope
      scope = VoiceCallLog.for_organization(organization)
      scope = scope.where(course_id: course_id) if course_id.present?
      scope = scope.where(started_at: start_date.beginning_of_day..end_date.end_of_day)
      scope
    end

    def total_calls_count
      base_scope.count
    end

    def completed_calls_count
      base_scope.where(status: 'completed').count
    end

    def error_rate_percentage
      total = total_calls_count
      return 0.0 if total.zero?
      
      error_count = base_scope.where(status: 'error').count
      (error_count.to_f / total * 100).round(2)
    end

    def average_duration_seconds
      completed_calls = base_scope.where(status: 'completed').where.not(duration_seconds: nil)
      return 0 if completed_calls.empty?
      
      completed_calls.average(:duration_seconds).to_f.round(0)
    end

    def booking_conversion_rate_percentage
      total = total_calls_count
      return 0.0 if total.zero?
      
      converted_count = base_scope.select { |call| call.booking_created? }.count
      (converted_count.to_f / total * 100).round(2)
    end

    def calls_by_channel_data
      base_scope.group(:channel).count.map do |channel, count|
        {
          channel: channel,
          count: count
        }
      end
    end

    def calls_by_day_data
      # Group by date (not datetime) for day-by-day stats
      daily_counts = base_scope.group("DATE(started_at)").count
      
      # Fill in missing days with 0 calls
      (start_date..end_date).map do |date|
        {
          date: date,
          count: daily_counts[date] || 0
        }
      end
    end

    def top_callers_data
      # Get top 10 callers by number of calls
      caller_stats = base_scope.where.not(caller_phone: nil)
                              .group(:caller_phone, :caller_name)
                              .group("DATE(started_at)")
                              .select("caller_phone, caller_name, COUNT(*) as call_count, AVG(duration_seconds) as avg_duration")
                              .group_by { |stat| [stat.caller_phone, stat.caller_name] }

      caller_summaries = caller_stats.map do |(phone, name), stats|
        total_calls = stats.sum(&:call_count)
        avg_duration = stats.map(&:avg_duration).compact.sum / [stats.count, 1].max
        
        {
          phone: phone,
          name: name.presence || "Unknown",
          total_calls: total_calls,
          average_duration_seconds: avg_duration.to_f.round(0)
        }
      end

      caller_summaries.sort_by { |c| c[:total_calls] }.reverse.first(10)
    end
  end
end