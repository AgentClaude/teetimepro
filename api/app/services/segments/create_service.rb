# frozen_string_literal: true

module Segments
  class CreateService < ApplicationService
    attr_accessor :organization, :user, :name, :description, :filter_criteria, :is_dynamic

    validates :organization, :user, :name, :filter_criteria, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      segment = GolferSegment.new(
        organization: organization,
        created_by: user,
        name: name,
        description: description,
        filter_criteria: filter_criteria,
        is_dynamic: is_dynamic.nil? ? true : is_dynamic
      )

      unless segment.save
        return validation_failure(segment)
      end

      # Evaluate and cache count
      eval_result = EvaluateService.call(
        organization: organization,
        filter_criteria: filter_criteria
      )

      if eval_result.success?
        segment.update!(
          cached_count: eval_result.count,
          last_evaluated_at: Time.current
        )
      end

      success(segment: segment)
    rescue AuthorizationError => e
      failure([e.message])
    end
  end
end
