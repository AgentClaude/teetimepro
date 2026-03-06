module TeeSheets
  class GenerateTeeSheetService < ApplicationService
    attr_accessor :course, :date, :blocked_times

    validates :course, :date, presence: true

    def call
      return validation_failure(self) unless valid?

      # Idempotent: return existing tee sheet if already generated
      existing = TeeSheet.find_by(course: course, date: date)
      if existing
        return success(
          tee_sheet: existing,
          tee_times_count: existing.tee_times.count,
          already_existed: true
        )
      end

      return failure(["Course must have first_tee_time configured"]) unless course.first_tee_time.present?
      return failure(["Course must have last_tee_time configured"]) unless course.last_tee_time.present?

      ActiveRecord::Base.transaction do
        tee_sheet = TeeSheet.create!(course: course, date: date)

        generate_tee_times(tee_sheet)

        apply_blocked_times(tee_sheet) if blocked_times.present?

        success(
          tee_sheet: tee_sheet,
          tee_times_count: tee_sheet.tee_times.count,
          already_existed: false
        )
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def generate_tee_times(tee_sheet)
      current_time = build_datetime(course.first_tee_time)
      last_time = build_datetime(course.last_tee_time)
      interval = course.interval_minutes.minutes

      while current_time <= last_time
        price = calculate_price(current_time)

        TeeTime.create!(
          tee_sheet: tee_sheet,
          starts_at: current_time,
          max_players: course.max_players_per_slot,
          booked_players: 0,
          status: :available,
          price_cents: price&.cents,
          price_currency: "USD"
        )

        current_time += interval
      end
    end

    def build_datetime(time_of_day)
      return nil unless time_of_day

      Time.zone.parse("#{date} #{time_of_day.strftime('%H:%M')}")
    end

    def calculate_price(time)
      course.default_rate_for(date, time)
    end

    def apply_blocked_times(tee_sheet)
      blocked_times.each do |blocked|
        start_time = Time.zone.parse("#{date} #{blocked[:start]}")
        end_time = Time.zone.parse("#{date} #{blocked[:end]}")
        reason = blocked[:reason] || "Blocked"

        tee_sheet.tee_times
          .where(starts_at: start_time..end_time)
          .update_all(status: :blocked, notes: reason)
      end
    end
  end
end
