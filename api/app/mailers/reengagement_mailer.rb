# frozen_string_literal: true

class ReengagementMailer < ApplicationMailer
  def lapsed_golfer_email(user, campaign)
    @user = user
    @campaign = campaign
    @organization = campaign.organization
    @booking_url = generate_booking_url

    mail(
      to: user.email,
      subject: personalize_subject(campaign.subject, user),
      from: "#{@organization.name} <noreply@#{email_domain}>",
      reply_to: @organization.email
    )
  end

  helper_method :personalize_content

  def personalize_content(content, user)
    return '' if content.blank?
    
    content.gsub('{{first_name}}', user.first_name || 'Golfer')
           .gsub('{{name}}', user.full_name || 'Golfer')
           .gsub('{{golf_course}}', @organization.name)
  end

  private

  def personalize_subject(subject, user)
    personalize_content(subject, user)
  end

  def generate_booking_url
    # Generate a booking URL with tracking parameters
    base_url = Rails.application.routes.url_helpers.root_url(
      host: Rails.application.config.app_domain
    )
    
    "#{base_url}book?utm_source=email&utm_medium=reengagement&utm_campaign=#{@campaign.id}"
  end

  def email_domain
    Rails.application.config.app_domain || 'teetimespro.com'
  end
end