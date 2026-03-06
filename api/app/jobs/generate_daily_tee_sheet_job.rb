class GenerateDailyTeeSheetJob < ApplicationJob
  queue_as :default

  # Generate tee sheets for the next 7 days for all courses
  DAYS_AHEAD = 7

  def perform
    Course.find_each do |course|
      DAYS_AHEAD.times do |offset|
        date = Date.current + offset.days

        result = TeeSheets::GenerateTeeSheetService.call(
          course: course,
          date: date
        )

        if result.success?
          if result.data.already_existed
            Rails.logger.debug(
              "Tee sheet already exists for #{course.name} on #{date}, skipping"
            )
          else
            Rails.logger.info(
              "Generated tee sheet for #{course.name} on #{date}: " \
              "#{result.data.tee_times_count} tee times"
            )
          end
        else
          Rails.logger.error(
            "Failed to generate tee sheet for #{course.name} on #{date}: " \
            "#{result.error_messages}"
          )
        end
      end
    end
  end
end
