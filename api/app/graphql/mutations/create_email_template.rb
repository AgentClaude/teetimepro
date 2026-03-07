# frozen_string_literal: true

module Mutations
  class CreateEmailTemplate < BaseMutation
    argument :name, String, required: true
    argument :subject, String, required: true
    argument :body_html, String, required: true
    argument :body_text, String, required: false
    argument :category, String, required: false
    argument :merge_fields, [String], required: false

    field :template, Types::EmailTemplateType, null: true
    field :errors, [String], null: false

    def resolve(**args)
      org = require_auth!
      require_role!(:manager)

      result = Campaigns::CreateEmailTemplateService.call(
        organization: org,
        user: current_user,
        **args
      )

      if result.success?
        { template: result.data[:template], errors: [] }
      else
        { template: nil, errors: result.errors }
      end
    end
  end
end
