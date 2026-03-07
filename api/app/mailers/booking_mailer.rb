# frozen_string_literal: true

class BookingMailer < ApplicationMailer
  def confirmation(booking:, organization:)
    @booking = booking
    @user = booking.user
    @tee_time = booking.tee_time
    @course = @tee_time.course
    @organization = organization

    mail(
      to: @user.email,
      subject: "Booking Confirmed — #{@course.name} on #{@tee_time.date.strftime('%B %d, %Y')}"
    )
  end

  def cancellation(booking:, organization:)
    @booking = booking
    @user = booking.user
    @tee_time = booking.tee_time
    @course = @tee_time.course
    @organization = organization
    @refunded = booking.payment&.refunded?

    mail(
      to: @user.email,
      subject: "Booking Cancelled — #{@course.name} on #{@tee_time.date.strftime('%B %d, %Y')}"
    )
  end
end
