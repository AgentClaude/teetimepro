class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && user.can_manage_course?
  end

  def destroy?
    user.present? && user.can_manage_course?
  end

  # Ensure the record belongs to the user's organization
  def same_organization?
    return false unless user&.organization

    case record
    when Course
      record.organization_id == user.organization_id
    when Booking
      record.tee_time.course.organization_id == user.organization_id
    when TeeTime
      record.tee_sheet.course.organization_id == user.organization_id
    else
      true
    end
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
