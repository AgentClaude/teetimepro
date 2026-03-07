module Pricing
  class UpdateRuleService < ApplicationService
    attr_accessor :pricing_rule, :user, :name, :rule_type, :course_id, :conditions, 
                  :multiplier, :flat_adjustment_cents, :priority, :active, 
                  :start_date, :end_date

    validates :pricing_rule, :user, presence: true
    validates :rule_type, inclusion: { in: PricingRule::RULE_TYPES }, allow_nil: true
    validates :multiplier, numericality: { greater_than: 0 }, allow_nil: true
    validates :priority, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    def call
      return validation_failure(self) unless valid?

      authorize_user!

      update_pricing_rule
      
      if pricing_rule.save
        success(pricing_rule: pricing_rule)
      else
        validation_failure(pricing_rule)
      end
    rescue AuthorizationError => e
      failure([e.message])
    rescue => e
      failure(["Error updating pricing rule: #{e.message}"])
    end

    private

    def authorize_user!
      authorize_org_access!(user, pricing_rule.organization)
      authorize_role!(user, :admin)
    end

    def update_pricing_rule
      attributes = {}
      
      attributes[:name] = name if name.present?
      attributes[:rule_type] = rule_type if rule_type.present?
      attributes[:conditions] = conditions if conditions
      attributes[:multiplier] = multiplier if multiplier.present?
      attributes[:flat_adjustment_cents] = flat_adjustment_cents if flat_adjustment_cents.present?
      attributes[:priority] = priority if priority.present?
      attributes[:active] = active unless active.nil?
      attributes[:start_date] = start_date unless start_date.nil?
      attributes[:end_date] = end_date unless end_date.nil?
      
      if course_id.present?
        course = find_course
        attributes[:course] = course
      elsif course_id == ''
        attributes[:course] = nil
      end

      pricing_rule.assign_attributes(attributes)
    end

    def find_course
      course = pricing_rule.organization.courses.find_by(id: course_id)
      raise "Course not found or doesn't belong to organization" unless course
      course
    end
  end
end