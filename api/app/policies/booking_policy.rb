class BookingPolicy < ApplicationPolicy
  def show?
    same_organization? && (own_booking? || user.can_manage_bookings?)
  end

  def create?
    same_organization?
  end

  def update?
    same_organization? && user.can_manage_bookings?
  end

  def destroy?
    same_organization? && (own_booking? || user.can_manage_bookings?)
  end

  def check_in?
    same_organization? && user.can_manage_bookings?
  end

  private

  def own_booking?
    record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.can_manage_bookings?
        scope.for_organization(user.organization)
      else
        scope.where(user: user)
      end
    end
  end
end
