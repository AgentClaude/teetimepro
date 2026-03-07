# frozen_string_literal: true

class BookingReminderMailer < ApplicationMailer
  def reminder_24h(booking:, organization:)
    set_common_ivars(booking, organization)
    @hours_until = ((booking.starts_at - Time.current) / 1.hour).round

    mail(
      to: @user.email,
      subject: "Reminder: Tee Time Tomorrow at #{@course.name}"
    )
  end

  def morning_of(booking:, organization:)
    set_common_ivars(booking, organization)

    mail(
      to: @user.email,
      subject: "Today's Tee Time at #{@course.name} — #{@tee_time.formatted_time}"
    )
  end

  private

  def set_common_ivars(booking, organization)
    @booking = booking
    @user = booking.user
    @tee_time = booking.tee_time
    @course = @tee_time.course
    @organization = organization
  end
end
