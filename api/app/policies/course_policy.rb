class CoursePolicy < ApplicationPolicy
  def show?
    same_organization?
  end

  def create?
    same_organization? && user.can_manage_course?
  end

  def update?
    same_organization? && user.can_manage_course?
  end

  def destroy?
    same_organization? && (user.admin? || user.owner?)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(organization: user.organization)
    end
  end
end
