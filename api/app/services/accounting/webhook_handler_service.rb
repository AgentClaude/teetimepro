module Accounting
  class WebhookHandlerService < ApplicationService
    attr_accessor :provider, :payload, :headers

    validates :provider, presence: true, inclusion: { in: %w[quickbooks xero] }
    validates :payload, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        verify_webhook_signature!
        process_webhook_payload!
        
        success(message: "Webhook processed successfully")
      rescue => e
        Rails.logger.error "Webhook processing failed: #{e.message}"
        failure(errors: ["Webhook processing failed: #{e.message}"])
      end
    end

    private

    def verify_webhook_signature!
      case provider
      when 'quickbooks'
        verify_quickbooks_signature!
      when 'xero'
        verify_xero_signature!
      end
    end

    def verify_quickbooks_signature!
      # QuickBooks webhook signature verification
      # The signature is in the 'intuit-signature' header
      signature = headers['intuit-signature']
      return unless signature

      # This would verify the HMAC signature using the webhook token
      # For now, we'll just log it
      Rails.logger.info "QuickBooks webhook signature: #{signature}"
    end

    def verify_xero_signature!
      # Xero webhook signature verification  
      # The signature is in the 'x-xero-signature' header
      signature = headers['x-xero-signature']
      return unless signature

      # This would verify the HMAC signature using the webhook key
      # For now, we'll just log it
      Rails.logger.info "Xero webhook signature: #{signature}"
    end

    def process_webhook_payload!
      case provider
      when 'quickbooks'
        process_quickbooks_webhook!
      when 'xero'
        process_xero_webhook!
      end
    end

    def process_quickbooks_webhook!
      # QuickBooks webhooks contain notifications about entity changes
      # Sample payload structure:
      # {
      #   "eventNotifications": [
      #     {
      #       "realmId": "123456",
      #       "dataChangeEvent": {
      #         "entities": [
      #           {
      #             "name": "Customer",
      #             "id": "1",
      #             "operation": "Create"
      #           }
      #         ]
      #       }
      #     }
      #   ]
      # }

      event_notifications = payload['eventNotifications'] || []
      
      event_notifications.each do |notification|
        realm_id = notification['realmId']
        next unless realm_id

        # Find the integration for this realm
        integration = AccountingIntegration.find_by(realm_id: realm_id)
        next unless integration

        # Process data change events
        data_change_event = notification['dataChangeEvent']
        next unless data_change_event

        entities = data_change_event['entities'] || []
        entities.each do |entity|
          process_quickbooks_entity_change(integration, entity)
        end
      end
    end

    def process_xero_webhook!
      # Xero webhooks contain notifications about entity changes
      # Sample payload structure:
      # {
      #   "events": [
      #     {
      #       "resourceUrl": "https://api.xero.com/api.xro/2.0/Contacts/uuid",
      #       "resourceId": "uuid",
      #       "eventDateUtc": "2023-01-01T00:00:00Z",
      #       "eventType": "CREATE",
      #       "eventCategory": "CONTACT",
      #       "tenantId": "tenant-uuid",
      #       "tenantType": "ORGANISATION"
      #     }
      #   ]
      # }

      events = payload['events'] || []
      
      events.each do |event|
        tenant_id = event['tenantId']
        next unless tenant_id

        # Find the integration for this tenant
        integration = AccountingIntegration.find_by(tenant_id: tenant_id)
        next unless integration

        process_xero_entity_change(integration, event)
      end
    end

    def process_quickbooks_entity_change(integration, entity)
      entity_name = entity['name']
      entity_id = entity['id']
      operation = entity['operation']

      Rails.logger.info "QuickBooks #{operation} event for #{entity_name} (#{entity_id})"

      case entity_name
      when 'Invoice'
        handle_invoice_change(integration, entity_id, operation)
      when 'Payment'
        handle_payment_change(integration, entity_id, operation)
      when 'CreditMemo'
        handle_credit_memo_change(integration, entity_id, operation)
      end
    end

    def process_xero_entity_change(integration, event)
      event_type = event['eventType']
      event_category = event['eventCategory']
      resource_id = event['resourceId']

      Rails.logger.info "Xero #{event_type} event for #{event_category} (#{resource_id})"

      case event_category
      when 'INVOICE'
        handle_invoice_change(integration, resource_id, event_type)
      when 'PAYMENT'
        handle_payment_change(integration, resource_id, event_type)
      when 'CREDITNOTE'
        handle_credit_memo_change(integration, resource_id, event_type)
      end
    end

    def handle_invoice_change(integration, external_id, operation)
      # Find syncs related to this external invoice
      syncs = integration.accounting_syncs
                        .where(sync_type: 'invoice', external_id: external_id)

      syncs.each do |sync|
        case operation.upcase
        when 'CREATE', 'UPDATE'
          # Invoice was created/updated in accounting system
          Rails.logger.info "Invoice #{external_id} was #{operation.downcase}d"
        when 'DELETE'
          # Invoice was deleted in accounting system
          Rails.logger.info "Invoice #{external_id} was deleted"
          sync.fail!("Invoice was deleted in #{integration.provider}")
        end
      end
    end

    def handle_payment_change(integration, external_id, operation)
      # Similar logic for payment changes
      syncs = integration.accounting_syncs
                        .where(sync_type: 'payment', external_id: external_id)

      syncs.each do |sync|
        Rails.logger.info "Payment #{external_id} was #{operation.downcase}d"
      end
    end

    def handle_credit_memo_change(integration, external_id, operation)
      # Similar logic for credit memo/refund changes
      syncs = integration.accounting_syncs
                        .where(sync_type: 'refund', external_id: external_id)

      syncs.each do |sync|
        Rails.logger.info "Credit memo #{external_id} was #{operation.downcase}d"
      end
    end
  end
end