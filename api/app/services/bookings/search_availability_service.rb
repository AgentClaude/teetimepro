module Bookings
  class SearchAvailabilityService < ApplicationService
    attr_accessor :organization, :course_id, :date, :end_date,
                  :players, :time_preference, :include_pricing

    validates :organization, presence: true
    validates :date, presence: true
    validates :players, presence: true, numericality: { in: 1..5 }

    def initialize(**args)
      super
      @players ||= 1
      @end_date ||= @date
      @include_pricing = args.fetch(:include_pricing, true)
    end

    def call
      return validation_failure(self) unless valid?

      if end_date && end_date < date
        return failure(["End date must be on or after start date"])
      end

      if end_date && (end_date - date).to_i > 30
        return failure(["Date range cannot exceed 30 days"])
      end

      slots = fetch_available_slots
      slots = apply_time_preference(slots)
      results = build_results(slots)

      success(
        slots: results,
        total_available: results.size,
        date_range: {
          start_date: date,
          end_date: end_date || date,
          days: ((end_date || date) - date).to_i + 1
        },
        filters: {
          players: players,
          time_preference: time_preference,
          course_id: course_id
        }
      )
    rescue StandardError => e
      Rails.logger.error("Availability search error: #{e.message}")
      failure(["Failed to search availability: #{e.message}"])
    end

    private

    def course_scope
      scope = organization.courses
      scope = scope.where(id: course_id) if course_id.present?
      scope
    end

    def fetch_available_slots
      TeeTime
        .joins(tee_sheet: :course)
        .where(courses: { id: course_scope.select(:id) })
        .where(tee_sheets: { date: date..(end_date || date) })
        .available_for(players)
        .where("tee_times.starts_at > ?", Time.current)
        .includes(tee_sheet: :course)
        .order("tee_sheets.date ASC, tee_times.starts_at ASC")
    end

    def apply_time_preference(slots)
      return slots if time_preference.blank?

      case time_preference.downcase
      when "morning"
        slots.where("EXTRACT(hour FROM tee_times.starts_at) < 12")
      when "afternoon"
        slots.where("EXTRACT(hour FROM tee_times.starts_at) BETWEEN 12 AND 16")
      when "twilight"
        slots.where("EXTRACT(hour FROM tee_times.starts_at) > 16")
      else
        slots
      end
    end

    def build_results(slots)
      slots.map do |tee_time|
        result = {
          tee_time_id: tee_time.id,
          course_id: tee_time.course.id,
          course_name: tee_time.course.name,
          date: tee_time.date,
          starts_at: tee_time.starts_at,
          formatted_time: tee_time.formatted_time,
          available_spots: tee_time.available_spots,
          max_players: tee_time.max_players,
          booked_players: tee_time.booked_players,
          base_price_cents: tee_time.price_cents
        }

        if include_pricing && tee_time.price_cents&.positive?
          pricing = calculate_pricing(tee_time)
          result.merge!(pricing)
        else
          result[:dynamic_price_cents] = tee_time.price_cents
          result[:price_per_player_cents] = tee_time.price_cents
          result[:total_price_cents] = (tee_time.price_cents || 0) * players
          result[:has_dynamic_pricing] = false
          result[:applied_rules] = []
        end

        result
      end
    end

    def calculate_pricing(tee_time)
      pricing_result = Pricing::CalculatePriceService.call(tee_time: tee_time)

      if pricing_result.success?
        dynamic_cents = pricing_result.data[:dynamic_price_cents] || tee_time.price_cents
        {
          dynamic_price_cents: dynamic_cents,
          price_per_player_cents: dynamic_cents,
          total_price_cents: dynamic_cents * players,
          has_dynamic_pricing: pricing_result.data[:applied_rules]&.any? || false,
          applied_rules: pricing_result.data[:applied_rules] || []
        }
      else
        {
          dynamic_price_cents: tee_time.price_cents,
          price_per_player_cents: tee_time.price_cents,
          total_price_cents: (tee_time.price_cents || 0) * players,
          has_dynamic_pricing: false,
          applied_rules: []
        }
      end
    rescue => e
      Rails.logger.warn("Pricing calculation failed for tee_time #{tee_time.id}: #{e.message}")
      {
        dynamic_price_cents: tee_time.price_cents,
        price_per_player_cents: tee_time.price_cents,
        total_price_cents: (tee_time.price_cents || 0) * players,
        has_dynamic_pricing: false,
        applied_rules: []
      }
    end
  end
end
