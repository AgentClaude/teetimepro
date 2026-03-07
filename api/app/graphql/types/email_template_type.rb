# frozen_string_literal: true

module Types
  class EmailTemplateType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :subject, String, null: false
    field :body_html, String, null: false
    field :body_text, String, null: true
    field :category, String, null: false
    field :is_active, Boolean, null: false
    field :merge_fields, [String], null: false
    field :usage_count, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :created_by, Types::UserType, null: false
  end
end
