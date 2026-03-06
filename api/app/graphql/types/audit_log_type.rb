module Types
  class AuditLogType < Types::BaseObject
    field :id, ID, null: false
    field :event, String, null: false
    field :changed_by, String, null: true
    field :changes, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def changed_by
      whodunnit = object.whodunnit
      return nil unless whodunnit
      User.find_by(id: whodunnit)&.full_name || "User ##{whodunnit}"
    end

    def changes
      raw = object.object_changes
      return {} unless raw.present?

      parsed = YAML.safe_load(raw, permitted_classes: [Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone, BigDecimal]) rescue {}
      return {} unless parsed.is_a?(Hash)

      parsed.transform_values do |v|
        Array(v).map { |val| val.is_a?(Time) || val.is_a?(ActiveSupport::TimeWithZone) ? val.iso8601 : val }
      end
    end
  end
end
