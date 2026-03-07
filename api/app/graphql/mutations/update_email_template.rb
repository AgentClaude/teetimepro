# frozen_string_literal: true

module Mutations
  class UpdateEmailTemplate < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: false
    argument :subject, String, required: false
    argument :body_html, String, required: false
    argument :body_text, String, required: false
    argument :category, String, required: false
    argument :is_active, Boolean, required: false

    field :template, Types::EmailTemplateType, null: true
    field :errors, [String], null: false

    def resolve(id:, **args)
      org = require_auth!
      require_role!(:manager)

      begin
        template = org.email_templates.find(id)

        if template.update(args.compact)
          { template: template, errors: [] }
        else
          { template: nil, errors: template.errors.full_messages }
        end
      rescue ActiveRecord::RecordNotFound
        { template: nil, errors: ["Template not found"] }
      end
    end
  end
end
