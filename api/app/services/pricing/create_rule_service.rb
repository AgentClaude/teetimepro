module Pricing
  class CreateRuleService < ApplicationService
    attr_accessor :organization, :user, :name, :rule_type, :course_id, :conditions, 
                  :multiplier, :flat_adjustment_cents, :priority, :active, 
                  :start_date, :end_date

    validates :organization, :user, :name, :rule_type, presence: true
    validates :rule_type, inclusion: { in: PricingRule::RULE_TYPES }
    validates :multiplier, numericality: { greater_than: 0 }
    validates :priority, numericality: { greater_than_or_equal_to: 0 }

    def call
      return validation_failure(self) unless valid?

      authorize_user!

      pricing_rule = build_pricing_rule
      
      if pricing_rule.save
        success(pricing_rule: pricing_rule)
      else
        validation_failure(pricing_rule)
      end
    rescue AuthorizationError => e
      failure([e.message])
    rescue => e
      failure(["Error creating pricing rule: #{e.message}"])
    end

    private

    def authorize_user!
      authorize_org_access!(user, organization)
      authorize_role!(user, :admin)
    end

    def build_pricing_rule
      course = find_course if course_id.present?
      
      organization.pricing_rules.build(
        name: name,
        rule_type: rule_type,
        course: course,
        conditions: conditions || {},
        multiplier: multiplier || 1.0,
        flat_adjustment_cents: flat_adjustment_cents || 0,
        priority: priority || 0,
        active: active.nil? ? true : active,
        start_date: start_date,
        end_date: end_date
      )
    end

    def find_course
      course = organization.courses.find_by(id: course_id)
      raise "Course not found or doesn't belong to organization" unless course
      course
    end
  end
end