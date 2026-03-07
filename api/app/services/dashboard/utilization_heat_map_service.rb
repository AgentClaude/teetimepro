module Dashboard
  class UtilizationHeatMapService < ApplicationService
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
      return failure(["Date range cannot exceed 90 days"]) if (end_date - start_date).to_i > 90
      return failure(["Start date must be before end date"]) if start_date > end_date

      success(
        cells: build_heat_map_cells,
        summary: build_summary
      )
    rescue StandardError => e
      Rails.logger.error("Utilization heat map error: #{e.message}")
      failure(["Failed to generate utilization heat map: #{e.message}"])
    end

    private

    def course_scope
      scope = organization.courses
      scope = scope.where(id: course_id) if course_id.present?
      scope
    end

    def tee_time_scope
      TeeTime.joins(tee_sheet: :course)
             .where(courses: { id: course_scope.select(:id) })
             .where(tee_sheets: { date: start_date..end_date })
    end

    def build_heat_map_cells
      # Group tee times by date and hour, calculate utilization
      rows = tee_time_scope
        .select(
          "tee_sheets.date AS slot_date",
          "EXTRACT(hour FROM tee_times.starts_at) AS slot_hour",
          "SUM(tee_times.booked_players) AS total_booked",
          "SUM(tee_times.max_players) AS total_capacity",
          "COUNT(tee_times.id) AS slot_count"
        )
        .group("tee_sheets.date, EXTRACT(hour FROM tee_times.starts_at)")
        .order("tee_sheets.date, slot_hour")

      rows.map do |row|
        capacity = row.total_capacity.to_i
        booked = row.total_booked.to_i
        utilization = capacity.positive? ? ((booked.to_f / capacity) * 100).round(1) : 0.0

        {
          date: row.slot_date,
          hour: row.slot_hour.to_i,
          utilization_percentage: utilization,
          booked_players: booked,
          total_capacity: capacity,
          slot_count: row.slot_count.to_i
        }
      end
    end

    def build_summary
      total_capacity = tee_time_scope.sum(:max_players)
      total_booked = tee_time_scope.sum(:booked_players)
      overall_utilization = total_capacity.positive? ? ((total_booked.to_f / total_capacity) * 100).round(1) : 0.0

      # Find peak hour
      peak_data = tee_time_scope
        .select(
          "EXTRACT(hour FROM tee_times.starts_at) AS slot_hour",
          "SUM(tee_times.booked_players)::float / NULLIF(SUM(tee_times.max_players), 0) * 100 AS util_pct"
        )
        .group("EXTRACT(hour FROM tee_times.starts_at)")
        .order("util_pct DESC NULLS LAST")
        .first

      # Find peak day of week
      peak_day_data = tee_time_scope
        .select(
          "EXTRACT(dow FROM tee_sheets.date) AS day_of_week",
          "SUM(tee_times.booked_players)::float / NULLIF(SUM(tee_times.max_players), 0) * 100 AS util_pct"
        )
        .group("EXTRACT(dow FROM tee_sheets.date)")
        .order("util_pct DESC NULLS LAST")
        .first

      day_names = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

      {
        overall_utilization: overall_utilization,
        total_booked_players: total_booked,
        total_capacity: total_capacity,
        peak_hour: peak_data&.slot_hour&.to_i,
        peak_hour_utilization: peak_data&.util_pct&.round(1) || 0.0,
        peak_day_of_week: peak_day_data ? day_names[peak_day_data.day_of_week.to_i] : nil,
        peak_day_utilization: peak_day_data&.util_pct&.round(1) || 0.0,
        date_range_days: (end_date - start_date).to_i + 1
      }
    end
  end
end
