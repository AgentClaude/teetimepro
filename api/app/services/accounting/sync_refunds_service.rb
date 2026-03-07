module Accounting
  class SyncRefundsService < ApplicationService
    attr_accessor :payment, :refund_amount

    validates :payment, presence: true
    validates :refund_amount, presence: true, numericality: { greater_than: 0 }

    def call
      return failure(errors: errors.full_messages) if errors.any?
      return failure(errors: ["Payment is not refundable"]) unless payment.completed?

      begin
        find_integration!
        return success(message: "No accounting integration found") unless @integration

        create_sync_record!
        sync_refund!
        
        success(sync: @sync, refund_id: @external_refund_id)
      rescue => e
        @sync&.fail!(e.message)
        failure(errors: ["Failed to sync refund: #{e.message}"])
      end
    end

    private

    def find_integration!
      @integration = payment.booking.organization.accounting_integrations
                           .connected
                           .first
    end

    def create_sync_record!
      @sync = @integration.accounting_syncs.create!(
        syncable: payment,
        sync_type: 'refund'
      )
      @sync.start!
    end

    def sync_refund!
      case @integration.provider
      when 'quickbooks'
        sync_quickbooks_refund!
      when 'xero'
        sync_xero_refund!
      end
    end

    def sync_quickbooks_refund!
      refund_data = build_quickbooks_refund_data
      
      # This would call QuickBooks API to create credit memo
      # POST to https://sandbox-quickbooks.api.intuit.com/v3/company/{realmId}/creditmemo
      Rails.logger.info "Creating QuickBooks credit memo for payment #{payment.id}"
      
      # Simulate API response
      @external_refund_id = "QB_CM_#{SecureRandom.hex(8)}"
      external_data = {
        id: @external_refund_id,
        total_amt: refund_amount.to_f,
        txn_date: Date.current.strftime("%Y-%m-%d"),
        doc_number: "CM-#{payment.booking.confirmation_code}"
      }
      
      @sync.complete!(@external_refund_id, external_data)
    end

    def sync_xero_refund!
      refund_data = build_xero_refund_data
      
      # This would call Xero API to create credit note
      # POST to https://api.xero.com/api.xro/2.0/CreditNotes
      Rails.logger.info "Creating Xero credit note for payment #{payment.id}"
      
      # Simulate API response
      @external_refund_id = "XERO_CN_#{SecureRandom.hex(8)}"
      external_data = {
        credit_note_id: @external_refund_id,
        total: refund_amount.to_f,
        date: Date.current.strftime("%Y-%m-%d"),
        credit_note_number: "CN-#{payment.booking.confirmation_code}"
      }
      
      @sync.complete!(@external_refund_id, external_data)
    end

    def build_quickbooks_refund_data
      green_fees_account = @integration.account_for('green_fees') || '1' # Default account

      {
        Line: [
          {
            Amount: refund_amount.to_f,
            DetailType: "SalesItemLineDetail",
            SalesItemLineDetail: {
              ItemRef: { value: green_fees_account },
              Qty: 1,
              UnitPrice: refund_amount.to_f
            }
          }
        ],
        CustomerRef: {
          name: customer_name
        },
        DocNumber: "CM-#{payment.booking.confirmation_code}",
        TxnDate: Date.current.strftime("%Y-%m-%d"),
        PrivateNote: "Refund for cancelled booking ##{payment.booking.confirmation_code}"
      }
    end

    def build_xero_refund_data
      green_fees_account = @integration.account_for('green_fees') || '200' # Default sales account

      {
        Type: "ACCPAY",
        Contact: {
          Name: customer_name
        },
        Date: Date.current.strftime("%Y-%m-%d"),
        CreditNoteNumber: "CN-#{payment.booking.confirmation_code}",
        Reference: "Refund for booking ##{payment.booking.confirmation_code}",
        LineItems: [
          {
            Description: "Refund for cancelled tee time booking",
            Quantity: 1,
            UnitAmount: refund_amount.to_f,
            AccountCode: green_fees_account
          }
        ]
      }
    end

    def customer_name
      payment.booking.user.full_name.presence || payment.booking.user.email
    end
  end
end