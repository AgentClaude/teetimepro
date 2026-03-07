# frozen_string_literal: true

class WaitlistMailer < ApplicationMailer
  def slot_available(waitlist_entry:, organization:)
    @entry = waitlist_entry
    @user = waitlist_entry.user
    @tee_time = waitlist_entry.tee_time
    @course = @tee_time.course
    @organization = organization
    @available_spots = @tee_time.available_spots

    mail(
      to: @user.email,
      subject: "A tee time you're waiting for is now available! — #{@course.name}"
    )
  end
end
