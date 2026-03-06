module Tournaments
  class WithdrawParticipantService < ApplicationService
    attr_accessor :tournament, :user

    validates :tournament, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      entry = tournament.tournament_entries.find_by(user: user)
      return failure(["Not registered for this tournament"]) unless entry

      if entry.withdrawn?
        return failure(["Already withdrawn from this tournament"])
      end

      if entry.disqualified?
        return failure(["Cannot withdraw — entry has been disqualified"])
      end

      if tournament.in_progress? || tournament.completed?
        return failure(["Cannot withdraw from a tournament that has started"])
      end

      entry.withdraw!

      # TODO: Process refund if payment was made and within refund window

      success(entry: entry)
    end
  end
end
