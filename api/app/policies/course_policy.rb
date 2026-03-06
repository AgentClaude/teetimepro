class CoursePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization?
  end

  def create?
    same_organization? && at_least_manager?
  end

  def update?
    same_organization? && at_least_manager?
  end

  def destroy?
    same_organization? && at_least_admin?
  end

  # View tee sheets for this course: all authenticated users in org
  def view_tee_sheets?
    same_organization?
  end

  # Manage tee sheets (block times, etc.): manager+
  def manage_tee_sheets?
    same_organization? && at_least_manager?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(organization: user.organization)
    end
  end
end
