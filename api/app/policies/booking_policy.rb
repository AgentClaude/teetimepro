class BookingPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_organization? && (own_booking? || at_least_staff?)
  end

  def create?
    same_organization?
  end

  def update?
    same_organization? && at_least_pro_shop?
  end

  def destroy?
    same_organization? && (own_booking? || at_least_pro_shop?)
  end

  # Cancel: golfers can cancel their own; pro_shop+ can cancel any
  def cancel?
    same_organization? && (own_booking? || at_least_pro_shop?)
  end

  # Check-in: staff and above
  def check_in?
    same_organization? && at_least_staff?
  end

  # Walk-on bookings: pro_shop and above
  def walk_on?
    same_organization? && at_least_pro_shop?
  end

  private

  def own_booking?
    record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.staff? || user.pro_shop? || user.manager? || user.admin? || user.owner?
        scope.for_organization(user.organization)
      else
        scope.where(user: user)
      end
    end
  end
end
