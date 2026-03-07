module Pricing
  class CalculatePriceService < ApplicationService
    attr_accessor :tee_time

    validates :tee_time, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(['Tee time has no base price']) if base_price_cents.zero?

      applicable_rules = find_applicable_rules
      dynamic_price_cents = apply_rules(applicable_rules)

      success(
        original_price_cents: base_price_cents,
        dynamic_price_cents: dynamic_price_cents,
        price_adjustment_cents: dynamic_price_cents - base_price_cents,
        applied_rules: serialize_rules(applicable_rules),
        price_breakdown: calculate_breakdown(applicable_rules)
      )
    rescue => e
      failure(["Error calculating price: #{e.message}"])
    end

    private

    def base_price_cents
      @base_price_cents ||= tee_time.price_cents || 0
    end

    def find_applicable_rules
      return [] unless tee_time.course&.organization

      PricingRule
        .active
        .for_organization(tee_time.course.organization.id)
        .valid_for_date(tee_time.date)
        .by_priority
        .select { |rule| rule.applicable_to_tee_time?(tee_time) }
    end

    def apply_rules(rules)
      total_multiplier = 1.0
      total_flat_adjustment_cents = 0

      rules.each do |rule|
        total_multiplier *= rule.multiplier
        total_flat_adjustment_cents += rule.flat_adjustment_cents
      end

      # Apply multiplier first, then add flat adjustments
      adjusted_price_cents = (base_price_cents * total_multiplier).round + total_flat_adjustment_cents

      # Ensure price doesn't go below zero
      [adjusted_price_cents, 0].max
    end

    def calculate_breakdown(rules)
      breakdown = [{
        step: 'base_price',
        description: 'Base tee time price',
        price_cents: base_price_cents,
        adjustment_cents: 0,
        multiplier: 1.0
      }]

      current_price_cents = base_price_cents
      cumulative_multiplier = 1.0

      rules.each do |rule|
        cumulative_multiplier *= rule.multiplier
        previous_price_cents = current_price_cents
        current_price_cents = (base_price_cents * cumulative_multiplier).round + 
                              rules.first(rules.index(rule) + 1).sum(&:flat_adjustment_cents)

        breakdown << {
          step: "rule_#{rule.id}",
          description: rule.name,
          rule_type: rule.rule_type,
          multiplier: rule.multiplier,
          flat_adjustment_cents: rule.flat_adjustment_cents,
          price_cents: current_price_cents,
          adjustment_cents: current_price_cents - previous_price_cents
        }
      end

      breakdown
    end

    def serialize_rules(rules)
      rules.map do |rule|
        {
          id: rule.id,
          name: rule.name,
          rule_type: rule.rule_type,
          multiplier: rule.multiplier,
          flat_adjustment_cents: rule.flat_adjustment_cents,
          priority: rule.priority,
          conditions: rule.conditions
        }
      end
    end
  end
end