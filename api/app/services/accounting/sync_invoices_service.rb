module Accounting
  class SyncInvoicesService < ApplicationService
    attr_accessor :booking

    validates :booking, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        find_integration!
        return success(message: "No accounting integration found") unless @integration

        create_sync_record!
        sync_invoice!
        
        success(sync: @sync, invoice_id: @external_invoice_id)
      rescue => e
        @sync&.fail!(e.message)
        failure(errors: ["Failed to sync invoice: #{e.message}"])
      end
    end

    private

    def find_integration!
      @integration = booking.organization.accounting_integrations
                           .connected
                           .first
    end

    def create_sync_record!
      @sync = @integration.accounting_syncs.create!(
        syncable: booking,
        sync_type: 'invoice'
      )
      @sync.start!
    end

    def sync_invoice!
      case @integration.provider
      when 'quickbooks'
        sync_quickbooks_invoice!
      when 'xero'
        sync_xero_invoice!
      end
    end

    def sync_quickbooks_invoice!
      invoice_data = build_quickbooks_invoice_data
      
      # This would call QuickBooks API to create invoice
      # POST to https://sandbox-quickbooks.api.intuit.com/v3/company/{realmId}/invoice
      Rails.logger.info "Creating QuickBooks invoice for booking #{booking.id}"
      
      # Simulate API response
      @external_invoice_id = "QB_INV_#{SecureRandom.hex(8)}"
      external_data = {
        id: @external_invoice_id,
        doc_number: "INV-#{booking.confirmation_code}",
        total_amt: booking.total.to_f,
        currency_ref: { value: "USD" }
      }
      
      @sync.complete!(@external_invoice_id, external_data)
    end

    def sync_xero_invoice!
      invoice_data = build_xero_invoice_data
      
      # This would call Xero API to create invoice  
      # POST to https://api.xero.com/api.xro/2.0/Invoices
      Rails.logger.info "Creating Xero invoice for booking #{booking.id}"
      
      # Simulate API response
      @external_invoice_id = "XERO_INV_#{SecureRandom.hex(8)}"
      external_data = {
        invoice_id: @external_invoice_id,
        invoice_number: "INV-#{booking.confirmation_code}",
        total: booking.total.to_f,
        currency_code: "USD"
      }
      
      @sync.complete!(@external_invoice_id, external_data)
    end

    def build_quickbooks_invoice_data
      green_fees_account = @integration.account_for('green_fees') || '1' # Default account

      {
        Line: [
          {
            Amount: booking.total.to_f,
            DetailType: "SalesItemLineDetail",
            SalesItemLineDetail: {
              ItemRef: { value: green_fees_account },
              Qty: booking.players_count,
              UnitPrice: (booking.total.to_f / booking.players_count).round(2)
            }
          }
        ],
        CustomerRef: {
          name: customer_name
        },
        DueDate: (booking.starts_at + 30.days).strftime("%Y-%m-%d"),
        DocNumber: "INV-#{booking.confirmation_code}",
        PrivateNote: "Tee time booking for #{booking.starts_at.strftime('%B %d, %Y at %l:%M %p')}"
      }
    end

    def build_xero_invoice_data
      green_fees_account = @integration.account_for('green_fees') || '200' # Default sales account

      {
        Type: "ACCREC",
        Contact: {
          Name: customer_name
        },
        Date: Date.current.strftime("%Y-%m-%d"),
        DueDate: (booking.starts_at + 30.days).strftime("%Y-%m-%d"),
        InvoiceNumber: "INV-#{booking.confirmation_code}",
        Reference: "Booking ##{booking.confirmation_code}",
        LineItems: [
          {
            Description: "Tee time booking - #{booking.starts_at.strftime('%B %d, %Y at %l:%M %p')}",
            Quantity: booking.players_count,
            UnitAmount: (booking.total.to_f / booking.players_count).round(2),
            AccountCode: green_fees_account
          }
        ]
      }
    end

    def customer_name
      booking.user.full_name.presence || booking.user.email
    end
  end
end
