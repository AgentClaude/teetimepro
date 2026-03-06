module Tournaments
  class UpdateTournamentService < ApplicationService
    attr_accessor :tournament, :user, :attributes

    validates :tournament, :user, :attributes, presence: true

    UPDATABLE_ATTRIBUTES = %i[
      name description format start_date end_date max_participants
      min_participants team_size entry_fee_cents holes handicap_enabled
      max_handicap rules prize_structure registration_opens_at
      registration_closes_at status
    ].freeze

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, tournament.organization)
      authorize_role!(user, :manager)

      validate_status_transition! if attributes.key?(:status)
      validate_no_entries_change! if format_changing?

      filtered = attributes.slice(*UPDATABLE_ATTRIBUTES)
      tournament.assign_attributes(filtered)

      if tournament.save
        success(tournament: tournament)
      else
        validation_failure(tournament)
      end
    rescue AuthorizationError => e
      failure([e.message])
    rescue InvalidTransitionError => e
      failure([e.message])
    end

    private

    def validate_status_transition!
      new_status = attributes[:status].to_s
      allowed = allowed_transitions[tournament.status] || []

      unless allowed.include?(new_status)
        raise InvalidTransitionError,
              "Cannot transition from #{tournament.status} to #{new_status}"
      end
    end

    def allowed_transitions
      {
        "draft" => %w[registration_open cancelled],
        "registration_open" => %w[registration_closed cancelled],
        "registration_closed" => %w[in_progress registration_open cancelled],
        "in_progress" => %w[completed cancelled],
        "completed" => [],
        "cancelled" => []
      }
    end

    def format_changing?
      attributes.key?(:format) && attributes[:format].to_s != tournament.format
    end

    def validate_no_entries_change!
      if tournament.tournament_entries.active.any?
        raise InvalidTransitionError,
              "Cannot change format with active entries"
      end
    end

    class InvalidTransitionError < StandardError; end
  end
end
