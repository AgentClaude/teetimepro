module Mutations
  class SyncAccountingData < BaseMutation
    argument :sync_type, Types::AccountingSyncTypeEnum, required: false
    argument :force, Boolean, required: false

    field :success, Boolean, null: false
    field :message, String, null: true
    field :errors, [String], null: false

    def resolve(sync_type: nil, force: false)
      org = require_auth!
      require_role!(:manager)

      # Check if there's an active integration
      integration = org.accounting_integrations.connected.first
      unless integration
        return { success: false, message: nil, errors: ["No connected accounting integration found"] }
      end

      # Queue the sync job
      AccountingSyncJob.perform_later(org.id, sync_type: sync_type, force: force)

      sync_message = if sync_type
                       "#{sync_type.titleize} sync"
                     else
                       "Full accounting sync"
                     end

      { success: true, message: "#{sync_message} queued successfully", errors: [] }
    rescue => e
      { success: false, message: nil, errors: ["Failed to queue sync: #{e.message}"] }
    end
  end
end
