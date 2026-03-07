class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("MAILER_FROM_EMAIL", "noreply@teetimespro.com") }
  layout "mailer"

  protected

  def organization_from_booking(booking)
    booking.course.organization
  end

  def set_organization_context(organization)
    @organization = organization
    @organization_name = organization.name
    @logo_url = organization.logo_url if organization.respond_to?(:logo_url)
  end
end