class GenerateDailyTeeSheetJob < ApplicationJob
  queue_as :default

  # Generate tee sheets for the next N days for all courses
  DAYS_AHEAD = 14

  def perform
    Course.find_each do |course|
      DAYS_AHEAD.times do |offset|
        date = Date.current + offset.days
        next if TeeSheet.exists?(course: course, date: date)

        result = TeeSheets::GenerateTeeSheetService.call(
          course: course,
          date: date
        )

        if result.success?
          Rails.logger.info(
            "Generated tee sheet for #{course.name} on #{date}: " \
            "#{result.data.tee_times_count} tee times"
          )
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
