# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  belongs_to :organization
  belongs_to :created_by, class_name: "User"
  has_many :email_campaigns, dependent: :nullify

  CATEGORIES = %w[general re-engagement promotion newsletter transactional].freeze

  validates :name, presence: true
  validates :subject, presence: true
  validates :body_html, presence: true
  validates :category, inclusion: { in: CATEGORIES }

  scope :active, -> { where(is_active: true) }
  scope :by_organization, ->(org) { where(organization: org) }
  scope :by_category, ->(category) { where(category: category) }

  # Default merge fields available in all templates
  STANDARD_MERGE_FIELDS = %w[
    {{first_name}}
    {{last_name}}
    {{full_name}}
    {{email}}
    {{organization_name}}
    {{unsubscribe_url}}
    {{current_date}}
  ].freeze

  # Render the template with merge field values
  def render_html(merge_data = {})
    rendered = body_html.dup
    merge_data.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end
    rendered
  end

  def render_text(merge_data = {})
    text = body_text.presence || strip_html(body_html)
    merge_data.each do |key, value|
      text.gsub!("{{#{key}}}", value.to_s)
    end
    text
  end

  def render_subject(merge_data = {})
    rendered = subject.dup
    merge_data.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end
    rendered
  end

  def increment_usage!
    increment!(:usage_count)
  end

  private

  def strip_html(html_content)
    html_content&.gsub(/<[^>]*>/, "")&.gsub(/\s+/, " ")&.strip
  end
end
