module TeeSheets
  class UpdateTeeTimeService < ApplicationService
    attr_accessor :tee_time, :status, :price_cents, :notes, :max_players

    validates :tee_time, presence: true

    def call
      return validation_failure(self) unless valid?

      if status.present? && tee_time.bookings.where.not(status: :cancelled).exists?
        if status.to_sym == :blocked || status.to_sym == :maintenance
          return failure(["Cannot block a tee time with active bookings"])
        end
      end

      attrs = {}
      attrs[:status] = status if status.present?
      attrs[:price_cents] = price_cents if price_cents.present?
      attrs[:notes] = notes if notes.present?
      attrs[:max_players] = max_players if max_players.present?

      tee_time.update!(attrs)

      success(tee_time: tee_time)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
