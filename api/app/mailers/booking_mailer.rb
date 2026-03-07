class BookingMailer < ApplicationMailer
  def confirmation_email(booking)
    @booking = booking
    @user = booking.user
    @tee_time = booking.tee_time
    @course = @tee_time.course
    @organization = organization_from_booking(booking)

    set_organization_context(@organization)
    set_booking_details

    mail(
      to: @user.email,
      subject: "Tee Time Confirmed - #{@course.name} - #{@formatted_date}"
    )
  end

  def cancellation_email(booking)
    @booking = booking
    @user = booking.user
    @tee_time = booking.tee_time
    @course = @tee_time.course
    @organization = organization_from_booking(booking)

    set_organization_context(@organization)
    set_booking_details

    mail(
      to: @user.email,
      subject: "Tee Time Cancelled - #{@course.name} - #{@formatted_date}"
    )
  end

  private

  def set_booking_details
    @confirmation_code = @booking.confirmation_code
    @players_count = @booking.players_count
    @formatted_date = @tee_time.date.strftime('%A, %B %d, %Y')
    @formatted_time = @tee_time.respond_to?(:formatted_time) ? 
                      @tee_time.formatted_time : 
                      @tee_time.starts_at.strftime('%l:%M %p')
    @cancellation_policy = build_cancellation_policy
  end

  def build_cancellation_policy
    if @booking.cancellable?
      "You can cancel this booking up to 24 hours before your tee time for a full refund."
    else
      "This booking cannot be cancelled as it is within 24 hours of your tee time."
    end
  end
end