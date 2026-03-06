module Bookings
  class CheckAvailabilityService < ApplicationService
    attr_accessor :tee_time, :players_count

    validates :tee_time, :players_count, presence: true

    def call
      return validation_failure(self) unless valid?

      if tee_time.blocked?
        return failure(["This tee time is blocked"])
      end

      if tee_time.maintenance?
        return failure(["This tee time is under maintenance"])
      end

      if tee_time.fully_booked?
        return failure(["This tee time is fully booked"])
      end

      if tee_time.available_spots < players_count
        return failure(["Only #{tee_time.available_spots} spots available, requested #{players_count}"])
      end

      if tee_time.starts_at <= Time.current
        return failure(["Cannot book tee times in the past"])
      end

      success(
        available: true,
        available_spots: tee_time.available_spots,
        price_per_player: tee_time.price_cents
      )
    end
  end
end
