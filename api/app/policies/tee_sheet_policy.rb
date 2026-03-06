class TeeSheetPolicy < ApplicationPolicy
  def index?
    same_organization?
  end

  def show?
    same_organization?
  end

  # Only managers+ can create/modify tee sheets directly
  def create?
    same_organization? && at_least_manager?
  end

  def update?
    same_organization? && at_least_manager?
  end

  def destroy?
    same_organization? && at_least_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:course).where(courses: { organization_id: user.organization_id })
    end
  end
end
