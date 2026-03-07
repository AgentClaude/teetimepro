module FoodBeverage
  class OpenTabService < ApplicationService
    attr_accessor :organization, :user, :golfer_name, :course_id

    validates :organization, :user, :golfer_name, presence: true
    validates :course_id, presence: true

    def call
      return validation_failure(self) unless valid?

      course = find_course
      return failure(['Course not found']) unless course

      authorize_org_access!(user, organization)

      ActiveRecord::Base.transaction do
        tab = create_tab(course)
        
        # Broadcast real-time notification
        broadcast_tab_opened(tab)

        success(tab: tab)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Failed to open tab: #{e.message}"])
    end

    private

    def find_course
      organization.courses.find_by(id: course_id)
    end

    def create_tab(course)
      FnbTab.create!(
        organization: organization,
        course: course,
        user: user,
        golfer_name: golfer_name.strip,
        status: 'open',
        total_cents: 0,
        opened_at: Time.current
      )
    end

    def broadcast_tab_opened(tab)
      ActionCable.server.broadcast(
        "fnb_tabs_#{organization.id}",
        {
          type: 'tab.opened',
          tab: {
            id: tab.id,
            golfer_name: tab.golfer_name,
            course_name: tab.course.name,
            server_name: tab.user.full_name,
            opened_at: tab.opened_at.iso8601,
            total_cents: tab.total_cents
          },
          timestamp: Time.current.iso8601
        }
      )
    end
  end
end