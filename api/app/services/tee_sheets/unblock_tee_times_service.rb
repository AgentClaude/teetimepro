# frozen_string_literal: true

module TeeSheets
  class UnblockTeeTimesService < ApplicationService
    attr_accessor :organization, :tee_time_block_id, :user

    validates :organization, :tee_time_block_id, :user, presence: true

    def call
      return validation_failure(self) unless valid?

      block = TeeTimeBlock.find_by(id: tee_time_block_id, organization_id: organization.id)
      return failure(["Block not found"]) unless block
      return failure(["Block is already inactive"]) unless block.active?

      ActiveRecord::Base.transaction do
        restored = restore_tee_times!(block)
        block.update!(active: false)

        success(block: block, restored_count: restored)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    end

    private

    def restore_tee_times!(block)
      tee_times = TeeTime.where(tee_time_block_id: block.id)

      count = 0
      tee_times.find_each do |tee_time|
        restored_status = if tee_time.previous_status.present?
                            tee_time.previous_status
                          else
                            0 # available
                          end

        tee_time.update!(
          status: restored_status,
          previous_status: nil,
          tee_time_block_id: nil
        )
        count += 1
      end

      count
    end
  end
end
