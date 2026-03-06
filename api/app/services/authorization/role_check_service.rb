module Authorization
  class RoleCheckService < ApplicationService
    attr_accessor :user, :permission, :resource

    ROLE_HIERARCHY = {
      "golfer" => 0,
      "staff" => 1,
      "pro_shop" => 2,
      "manager" => 3,
      "admin" => 4,
      "owner" => 5
    }.freeze

    # Maps permissions to the minimum role required
    PERMISSION_MAP = {
      # Course management
      manage_courses: "manager",
      create_course: "manager",
      update_course: "manager",
      delete_course: "admin",
      view_course: "golfer",

      # Tee sheet management
      manage_tee_sheets: "manager",
      view_tee_sheet: "golfer",

      # Booking management
      manage_bookings: "pro_shop",
      create_booking: "golfer",
      cancel_own_booking: "golfer",
      cancel_any_booking: "pro_shop",
      check_in: "staff",

      # Walk-ons
      manage_walk_ons: "pro_shop",

      # User/org management
      manage_users: "admin",
      manage_organization: "owner",

      # Reports
      view_reports: "manager",

      # Profile
      view_own_profile: "golfer",
      update_own_profile: "golfer"
    }.freeze

    validates :user, :permission, presence: true

    def call
      return validation_failure(self) unless valid?

      minimum_role = PERMISSION_MAP[permission.to_sym]
      return failure(["Unknown permission: #{permission}"]) unless minimum_role

      if has_permission?(minimum_role)
        success(authorized: true)
      else
        failure(["Insufficient permissions"], authorized: false)
      end
    end

    private

    def has_permission?(minimum_role)
      user_level = ROLE_HIERARCHY[user.role] || 0
      required_level = ROLE_HIERARCHY[minimum_role] || 0
      user_level >= required_level
    end
  end
end
