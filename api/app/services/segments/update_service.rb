# frozen_string_literal: true

module Segments
  class UpdateService < ApplicationService
    attr_accessor :segment, :user, :name, :description, :filter_criteria, :is_dynamic

    validates :segment, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, segment.organization)
      authorize_role!(user, :manager)

      attrs = {}
      attrs[:name] = name if name.present?
      attrs[:description] = description unless description.nil?
      attrs[:filter_criteria] = filter_criteria if filter_criteria.present?
      attrs[:is_dynamic] = is_dynamic unless is_dynamic.nil?

      unless segment.update(attrs)
        return validation_failure(segment)
      end

      # Re-evaluate if criteria changed
      if filter_criteria.present?
        eval_result = EvaluateService.call(
          organization: segment.organization,
          filter_criteria: segment.filter_criteria
        )

        if eval_result.success?
          segment.update!(
            cached_count: eval_result.count,
            last_evaluated_at: Time.current
          )
        end
      end

      success(segment: segment)
    rescue AuthorizationError => e
      failure([e.message])
    end
  end
end
