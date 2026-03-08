# frozen_string_literal: true

module Prepaid
  class CreatePackageService < ApplicationService
    attr_accessor :organization, :name, :description, :package_type,
                  :rounds_included, :price_cents, :value_cents,
                  :validity_days, :max_players_per_round, :transferable,
                  :restrictions, :course_id, :available_from, :available_until

    validates :organization, :name, :price_cents, :package_type, presence: true

    def call
      return validation_failure(self) unless valid?

      package = PrepaidPackage.create!(
        organization: organization,
        course_id: course_id,
        name: name,
        description: description,
        package_type: package_type,
        rounds_included: rounds_included,
        price_cents: price_cents,
        value_cents: value_cents,
        validity_days: validity_days,
        max_players_per_round: max_players_per_round || 4,
        transferable: transferable || false,
        restrictions: restrictions || {},
        available_from: available_from,
        available_until: available_until
      )

      success(package: package)
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end
  end
end
