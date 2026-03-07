module Mutations
  class CalculateTeeTimePrice < BaseMutation
    description "Calculate dynamic pricing for a tee time"

    argument :tee_time_id, ID, required: true

    field :calculation, Types::PricingCalculationType, null: true
    field :errors, [String], null: false

    def resolve(tee_time_id:)
      tee_time = TeeTime.joins(tee_sheet: { course: :organization })
                         .where(course: { organization: current_organization })
                         .find(tee_time_id)

      result = ::Pricing::CalculatePriceService.call(tee_time: tee_time)

      if result.success?
        { 
          calculation: result.data,
          errors: []
        }
      else
        {
          calculation: nil,
          errors: result.errors
        }
      end
    rescue ActiveRecord::RecordNotFound
      {
        calculation: nil,
        errors: ["Tee time not found"]
      }
    end
  end
end