module Types
  class AccountingSyncType < Types::BaseObject
    field :id, ID, null: false
    field :accounting_integration, Types::AccountingIntegrationType, null: false
    field :syncable_type, String, null: false
    field :syncable_id, ID, null: false
    field :sync_type, Types::AccountingSyncTypeEnum, null: false
    field :status, Types::AccountingSyncStatusEnum, null: false
    field :external_id, String, null: true
    field :external_data, GraphQL::Types::JSON, null: true
    field :retry_count, Integer, null: false
    field :next_retry_at, GraphQL::Types::ISO8601DateTime, null: true
    field :error_message, String, null: true
    field :error_at, GraphQL::Types::ISO8601DateTime, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Helper fields
    field :sync_type_humanized, String, null: false
    field :provider, String, null: false
    field :duration, Float, null: true
    field :retryable, Boolean, null: false

    def sync_type_humanized
      object.sync_type_humanized
    end

    def provider
      object.provider
    end

    def duration
      object.duration
    end

    def retryable
      object.retryable?
    end

    # Polymorphic syncable field
    field :syncable, Types::AccountingSyncableUnion, null: false

    def syncable
      object.syncable
    end
  end
end