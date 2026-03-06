module Tournaments
  class RegisterParticipantService < ApplicationService
    attr_accessor :tournament, :user, :handicap_index, :team_name,
                  :payment_method_id

    validates :tournament, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      unless tournament.registration_available?
        return failure(["Tournament is not accepting registrations"])
      end

      if tournament.tournament_entries.exists?(user: user)
        return failure(["Already registered for this tournament"])
      end

      payment_failure = nil

      entry = ActiveRecord::Base.transaction do
        created_entry = tournament.tournament_entries.create!(
          user: user,
          handicap_index: handicap_index || user.golfer_profile&.handicap_index,
          team_name: team_name,
          status: tournament.entry_fee_cents.positive? ? :registered : :confirmed
        )

        if tournament.entry_fee_cents.positive? && payment_method_id.present?
          payment_result = Payments::ProcessPaymentService.call(
            booking: nil,
            payment_method_id: payment_method_id,
            amount_cents: tournament.entry_fee_cents,
            currency: tournament.entry_fee_currency,
            description: "Tournament entry: #{tournament.name}",
            stripe_account_id: tournament.organization.stripe_account_id
          )

          if payment_result.success?
            created_entry.update!(status: :confirmed, payment: payment_result.data.payment)
          else
            payment_failure = payment_result
            raise ActiveRecord::Rollback
          end
        end

        created_entry
      end

      return payment_failure if payment_failure
      return failure(["Registration failed"]) unless entry

      success(entry: entry)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
