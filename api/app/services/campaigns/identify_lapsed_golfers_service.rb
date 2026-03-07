# frozen_string_literal: true

module Campaigns
  class IdentifyLapsedGolfersService < ApplicationService
    attr_accessor :organization, :lapsed_days, :filter_criteria

    validates :organization, :lapsed_days, presence: true
    validates :lapsed_days, numericality: { greater_than: 0 }

    def call
      return validation_failure(self) unless valid?

      lapsed_golfers = find_lapsed_golfers
      success(golfers: lapsed_golfers, count: lapsed_golfers.count)
    end

    private

    def find_lapsed_golfers
      base_scope = organization.users.includes(:bookings)
                             .where(role: [:member, :player]) # Only golfers, not staff
                             .where.not(email: [nil, ''])    # Must have email

      # Find users with no recent bookings
      cutoff_date = lapsed_days.days.ago
      
      # Users who either have no bookings OR their last booking was before cutoff
      users_with_no_recent_bookings = base_scope.left_joins(:bookings)
                                               .group('users.id')
                                               .having('MAX(bookings.tee_time) IS NULL OR MAX(bookings.tee_time) < ?', cutoff_date)

      # Apply additional filters if specified
      apply_additional_filters(users_with_no_recent_bookings)
    end

    def apply_additional_filters(scope)
      return scope if filter_criteria.blank?

      filter_criteria.each do |key, value|
        scope = apply_filter(scope, key, value)
      end

      scope
    end

    def apply_filter(scope, key, value)
      case key
      when 'membership_status'
        apply_membership_status_filter(scope, value)
      when 'membership_tier'
        apply_membership_tier_filter(scope, value)
      when 'signup_within_days'
        scope.where('users.created_at >= ?', value.to_i.days.ago)
      when 'signup_before_days'
        scope.where('users.created_at <= ?', value.to_i.days.ago)
      when 'total_spent_min'
        scope.joins(:bookings)
             .group('users.id')
             .having('SUM(bookings.price_cents) >= ?', value.to_i)
      when 'total_spent_max'
        scope.joins(:bookings)
             .group('users.id')
             .having('SUM(bookings.price_cents) <= ?', value.to_i)
      when 'handicap_min'
        scope.where('users.handicap >= ?', value.to_f)
      when 'handicap_max'
        scope.where('users.handicap <= ?', value.to_f)
      else
        scope # Ignore unknown filters
      end
    end

    def apply_membership_status_filter(scope, status)
      case status
      when 'active'
        scope.joins(:memberships).where(memberships: { status: :active })
      when 'expired'
        scope.joins(:memberships).where(memberships: { status: :expired })
      when 'none'
        scope.left_joins(:memberships).where(memberships: { id: nil })
      else
        scope
      end
    end

    def apply_membership_tier_filter(scope, tier)
      if tier.is_a?(Array)
        scope.joins(:memberships).where(memberships: { tier: tier })
      else
        scope.joins(:memberships).where(memberships: { tier: tier })
      end
    end
  end
end