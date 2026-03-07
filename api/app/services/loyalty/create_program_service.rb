module Loyalty
  class CreateProgramService < ApplicationService
    attr_accessor :organization, :name, :description, :points_per_dollar, :tier_thresholds, :is_active

    validates :organization, presence: true
    validates :name, presence: true
    validates :points_per_dollar, presence: true, numericality: { greater_than: 0 }

    def call
      return validation_failure(self) if invalid?

      begin
        create_or_update_program!
        success(program: @program)
      rescue => e
        failure(["Failed to create loyalty program: #{e.message}"])
      end
    end

    private

    def create_or_update_program!
      @program = organization.loyalty_programs.first_or_initialize

      @program.assign_attributes(
        name: name,
        description: description,
        points_per_dollar: points_per_dollar,
        tier_thresholds: tier_thresholds || @program.default_tier_thresholds,
        is_active: is_active.nil? ? true : is_active
      )

      @program.save!
    end
  end
end