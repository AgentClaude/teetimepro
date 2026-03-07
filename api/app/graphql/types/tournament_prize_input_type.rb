module Types
  class TournamentPrizeInputType < Types::BaseInputObject
    argument :position, Integer, required: true
    argument :prize_type, String, required: true
    argument :description, String, required: true
    argument :amount_cents, Integer, required: false
  end
end