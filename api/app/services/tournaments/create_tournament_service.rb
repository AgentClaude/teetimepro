module Tournaments
  class CreateTournamentService < ApplicationService
    attr_accessor :organization, :course, :user, :name, :description,
                  :format, :start_date, :end_date, :max_participants,
                  :min_participants, :team_size, :entry_fee_cents,
                  :holes, :handicap_enabled, :max_handicap, :rules,
                  :prize_structure, :registration_opens_at, :registration_closes_at

    validates :organization, :course, :user, :name, :format,
              :start_date, :end_date, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      tournament = Tournament.new(
        organization: organization,
        course: course,
        created_by: user,
        name: name,
        description: description,
        format: format,
        start_date: start_date,
        end_date: end_date,
        max_participants: max_participants,
        min_participants: min_participants || 2,
        team_size: team_size || default_team_size,
        entry_fee_cents: entry_fee_cents || 0,
        holes: holes || 18,
        handicap_enabled: handicap_enabled.nil? ? true : handicap_enabled,
        max_handicap: max_handicap,
        rules: rules || {},
        prize_structure: prize_structure || {},
        registration_opens_at: registration_opens_at,
        registration_closes_at: registration_closes_at,
        status: :draft
      )

      if tournament.save
        success(tournament: tournament)
      else
        validation_failure(tournament)
      end
    rescue AuthorizationError => e
      failure([e.message])
    end

    private

    def default_team_size
      case format&.to_s
      when "scramble", "best_ball" then 4
      else 1
      end
    end
  end
end
