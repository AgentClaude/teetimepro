class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present? && same_organization?
  end

  def create?
    user.present? && same_organization?
  end

  def update?
    user.present? && same_organization? && at_least_manager?
  end

  def destroy?
    user.present? && same_organization? && at_least_admin?
  end

  private

  # Role hierarchy checks
  def owner_or_admin?
    user.admin? || user.owner?
  end

  def at_least_admin?
    owner_or_admin?
  end

  def at_least_manager?
    user.manager? || owner_or_admin?
  end

  def at_least_pro_shop?
    user.pro_shop? || at_least_manager?
  end

  def at_least_staff?
    user.staff? || at_least_pro_shop?
  end

  # Organization scoping — ensures the record belongs to the user's org
  def same_organization?
    return true unless user&.organization_id
    return true unless record

    org_id = record_organization_id
    return true if org_id.nil? # Can't determine org, allow (policy should handle)

    org_id == user.organization_id
  end

  def record_organization_id
    case record
    when Course
      record.organization_id
    when Booking
      record.tee_time&.tee_sheet&.course&.organization_id
    when TeeTime
      record.tee_sheet&.course&.organization_id
    when TeeSheet
      record.course&.organization_id
    when User
      record.organization_id
    else
      nil
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
