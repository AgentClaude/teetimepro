# frozen_string_literal: true

module Segments
  # Evaluates filter criteria and returns matching users.
  # Used for both previewing and refreshing segment membership.
  class EvaluateService < ApplicationService
    attr_accessor :organization, :filter_criteria

    validates :organization, presence: true
    validate :filter_criteria_must_be_hash

    def call
      return validation_failure(self) unless valid?

      scope = organization.users.where(role: :golfer)
      scope = apply_filters(scope)

      # Wrap in subquery to get a flat count — .count on grouped scopes returns a Hash
      matching_ids = scope.distinct.select("users.id")
      user_scope = organization.users.where(id: matching_ids)

      success(users: user_scope, count: user_scope.count)
    rescue StandardError => e
      failure(["Failed to evaluate segment: #{e.message}"])
    end

    private

    def filter_criteria_must_be_hash
      errors.add(:filter_criteria, "must be a Hash") unless filter_criteria.is_a?(Hash)
    end

    def apply_filters(scope)
      criteria = filter_criteria.with_indifferent_access

      scope = apply_booking_count_filters(scope, criteria)
      scope = apply_last_booking_filters(scope, criteria)
      scope = apply_membership_filters(scope, criteria)
      scope = apply_spending_filters(scope, criteria)
      scope = apply_signup_filters(scope, criteria)
      scope = apply_role_filter(scope, criteria)
      scope = apply_handicap_filters(scope, criteria)

      scope
    end

    def apply_booking_count_filters(scope, criteria)
      if criteria[:booking_count_min].present? || criteria[:booking_count_max].present?
        scope = scope.left_joins(:bookings)
                     .group("users.id")

        if criteria[:booking_count_min].present?
          scope = scope.having("COUNT(bookings.id) >= ?", criteria[:booking_count_min].to_i)
        end

        if criteria[:booking_count_max].present?
          scope = scope.having("COUNT(bookings.id) <= ?", criteria[:booking_count_max].to_i)
        end
      end

      scope
    end

    def apply_last_booking_filters(scope, criteria)
      if criteria[:last_booking_within_days].present?
        cutoff = criteria[:last_booking_within_days].to_i.days.ago
        scope = scope.where(
          id: Booking.where("bookings.created_at >= ?", cutoff)
                     .select(:user_id)
        )
      end

      if criteria[:last_booking_before_days].present?
        cutoff = criteria[:last_booking_before_days].to_i.days.ago
        # Users whose most recent booking is before the cutoff (lapsed)
        recent_bookers = Booking.where("bookings.created_at >= ?", cutoff).select(:user_id)
        scope = scope.where.not(id: recent_bookers)
                     .where(id: Booking.select(:user_id)) # Must have at least one booking
      end

      scope
    end

    def apply_membership_filters(scope, criteria)
      if criteria[:membership_tier].present?
        tiers = Array(criteria[:membership_tier])
        scope = scope.joins(:membership)
                     .where(memberships: { tier: tiers })
      end

      if criteria[:membership_status].present?
        case criteria[:membership_status]
        when "active"
          scope = scope.where(
            id: Membership.active.select(:user_id)
          )
        when "expired"
          scope = scope.where(
            id: Membership.where(status: :expired).select(:user_id)
          )
        when "none"
          scope = scope.where.not(
            id: Membership.select(:user_id)
          )
        end
      end

      scope
    end

    def apply_spending_filters(scope, criteria)
      if criteria[:total_spent_min].present? || criteria[:total_spent_max].present?
        scope = scope.left_joins(:bookings)
                     .where(bookings: { status: :confirmed })
                     .group("users.id")

        if criteria[:total_spent_min].present?
          scope = scope.having("COALESCE(SUM(bookings.total_cents), 0) >= ?", criteria[:total_spent_min].to_i)
        end

        if criteria[:total_spent_max].present?
          scope = scope.having("COALESCE(SUM(bookings.total_cents), 0) <= ?", criteria[:total_spent_max].to_i)
        end
      end

      scope
    end

    def apply_signup_filters(scope, criteria)
      if criteria[:signup_within_days].present?
        scope = scope.where("users.created_at >= ?", criteria[:signup_within_days].to_i.days.ago)
      end

      if criteria[:signup_before_days].present?
        scope = scope.where("users.created_at < ?", criteria[:signup_before_days].to_i.days.ago)
      end

      scope
    end

    def apply_role_filter(scope, criteria)
      if criteria[:role].present?
        roles = Array(criteria[:role])
        scope = scope.where(role: roles)
      end

      scope
    end

    def apply_handicap_filters(scope, criteria)
      if criteria[:handicap_min].present? || criteria[:handicap_max].present?
        scope = scope.joins(:golfer_profile)

        if criteria[:handicap_min].present?
          scope = scope.where("golfer_profiles.handicap_index >= ?", criteria[:handicap_min].to_f)
        end

        if criteria[:handicap_max].present?
          scope = scope.where("golfer_profiles.handicap_index <= ?", criteria[:handicap_max].to_f)
        end
      end

      scope
    end
  end
end
