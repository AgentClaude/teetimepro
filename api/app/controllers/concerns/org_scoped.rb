module OrgScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
    before_action :verify_organization_membership
  end

  private

  def set_current_organization
    if current_user
      Organization.current = current_user.organization
    else
      Organization.current = nil
    end
  end

  def verify_organization_membership
    return unless current_user

    unless current_user.organization.present?
      render json: { error: "User is not associated with an organization" }, status: :forbidden
    end
  end

  # Scoped query helpers for controllers
  def current_organization
    Organization.current
  end

  def scoped_courses
    current_organization.courses
  end

  def scoped_tee_sheets
    TeeSheet.joins(:course).where(courses: { organization_id: current_organization.id })
  end

  def scoped_bookings
    Booking.for_organization(current_organization)
  end

  def scoped_users
    current_organization.users
  end
end
