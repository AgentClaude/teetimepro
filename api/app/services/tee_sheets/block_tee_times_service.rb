# frozen_string_literal: true

module TeeSheets
  class BlockTeeTimesService < ApplicationService
    attr_accessor :organization, :course, :user, :block_type,
                  :reason, :description, :starts_at, :ends_at

    validates :organization, :course, :user, :reason, :starts_at, :ends_at, :block_type, presence: true

    def call
      return validation_failure(self) unless valid?
      return failure(["End time must be after start time"]) unless ends_at > starts_at
      return failure(["Cannot block times in the past"]) if ends_at <= Time.current
      return failure(["Course does not belong to this organization"]) unless course.organization_id == organization.id

      ActiveRecord::Base.transaction do
        block = create_block!
        affected = block_tee_times!(block)
        block.update!(affected_tee_time_count: affected)

        success(block: block, affected_count: affected)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def create_block!
      TeeTimeBlock.create!(
        organization: organization,
        course: course,
        created_by: user,
        block_type: block_type,
        reason: reason,
        description: description,
        starts_at: starts_at,
        ends_at: ends_at
      )
    end

    def block_tee_times!(block)
      tee_times = TeeTime.joins(:tee_sheet)
                         .where(tee_sheets: { course_id: course.id })
                         .where(starts_at: starts_at..ends_at)
                         .where.not(status: [:blocked, :maintenance])

      count = 0
      tee_times.find_each do |tee_time|
        next if tee_time.bookings.where.not(status: :cancelled).exists?

        tee_time.update!(
          previous_status: TeeTime.statuses[tee_time.status],
          tee_time_block_id: block.id,
          status: block_status_for(block)
        )
        count += 1
      end

      count
    end

    def block_status_for(block)
      block.maintenance? ? :maintenance : :blocked
    end
  end
end
