# frozen_string_literal: true

module Campaigns
  class CreateEmailTemplateService < ApplicationService
    attr_accessor :organization, :user, :name, :subject, :body_html,
                  :body_text, :category, :merge_fields

    validates :organization, :user, :name, :subject, :body_html, presence: true

    def call
      return validation_failure(self) unless valid?

      authorize_org_access!(user, organization)
      authorize_role!(user, :manager)

      template = EmailTemplate.new(
        organization: organization,
        created_by: user,
        name: name,
        subject: subject,
        body_html: body_html,
        body_text: body_text || strip_html(body_html),
        category: category || "general",
        merge_fields: merge_fields || EmailTemplate::STANDARD_MERGE_FIELDS
      )

      if template.save
        success(template: template)
      else
        validation_failure(template)
      end
    end

    private

    def strip_html(html_content)
      html_content&.gsub(/<[^>]*>/, "")&.gsub(/\s+/, " ")&.strip
    end
  end
end
