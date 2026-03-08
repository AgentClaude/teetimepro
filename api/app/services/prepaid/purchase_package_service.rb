# frozen_string_literal: true

module Prepaid
  class PurchasePackageService < ApplicationService
    attr_accessor :prepaid_package, :user, :organization, :payment

    validates :prepaid_package, :user, :organization, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["Package is not available for purchase"]) unless prepaid_package.available?
      return failure(["Package does not belong to this organization"]) unless prepaid_package.organization_id == organization.id

      purchase = PrepaidPurchase.create!(
        prepaid_package: prepaid_package,
        organization: organization,
        user: user,
        payment: payment,
        status: :active,
        rounds_remaining: prepaid_package.round_pack? ? prepaid_package.rounds_included : nil,
        balance_cents: prepaid_package.value_card? ? prepaid_package.value_cents : nil,
        purchased_at: Time.current,
        activated_at: Time.current,
        expires_at: calculate_expiry
      )

      success(purchase: purchase)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def calculate_expiry
      return nil unless prepaid_package.validity_days.present?

      prepaid_package.validity_days.days.from_now
    end
  end
end
