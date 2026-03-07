# frozen_string_literal: true

module Segments
  class DeleteService < ApplicationService
    attr_accessor :segment, :user

    validates :segment, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, segment.organization)
      authorize_role!(user, :manager)

      segment.destroy!

      success(deleted: true)
    rescue AuthorizationError => e
      failure([e.message])
    end
  end
end
