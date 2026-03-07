module Accounting
  class SyncPaymentsService < ApplicationService
    attr_accessor :payment

    validates :payment, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?
      return failure(errors: ["Payment is not completed"]) unless payment.completed?

      begin
        find_integration!
        return success(message: "No accounting integration found") unless @integration

        create_sync_record!
        sync_payment!
        
        success(sync: @sync, payment_id: @external_payment_id)
      rescue => e
        @sync&.fail!(e.message)
        failure(errors: ["Failed to sync payment: #{e.message}"])
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
        sync_type: 'payment'
      )
      @sync.start!
    end

    def sync_payment!
      case @integration.provider
      when 'quickbooks'
        sync_quickbooks_payment!
      when 'xero'
        sync_xero_payment!
      end
    end

    def sync_quickbooks_payment!
      payment_data = build_quickbooks_payment_data
      
      # This would call QuickBooks API to create payment
      # POST to https://sandbox-quickbooks.api.intuit.com/v3/company/{realmId}/payment
      Rails.logger.info "Creating QuickBooks payment for payment #{payment.id}"
      
      # Simulate API response
      @external_payment_id = "QB_PAY_#{SecureRandom.hex(8)}"
      external_data = {
        id: @external_payment_id,
        total_amt: payment.amount.to_f,
        txn_date: payment.created_at.strftime("%Y-%m-%d"),
        payment_ref_num: payment.stripe_payment_intent_id
      }
      
      @sync.complete!(@external_payment_id, external_data)
    end

    def sync_xero_payment!
      payment_data = build_xero_payment_data
      
      # This would call Xero API to create payment
      # POST to https://api.xero.com/api.xro/2.0/Payments
      Rails.logger.info "Creating Xero payment for payment #{payment.id}"
      
      # Simulate API response
      @external_payment_id = "XERO_PAY_#{SecureRandom.hex(8)}"
      external_data = {
        payment_id: @external_payment_id,
        amount: payment.amount.to_f,
        date: payment.created_at.strftime("%Y-%m-%d"),
        reference: payment.stripe_payment_intent_id
      }
      
      @sync.complete!(@external_payment_id, external_data)
    end

    def build_quickbooks_payment_data
      deposit_account = @integration.account_for('bank_deposits') || '35' # Default checking account

      {
        TotalAmt: payment.amount.to_f,
        CustomerRef: {
          name: customer_name
        },
        DepositToAccountRef: {
          value: deposit_account
        },
        PaymentMethodRef: {
          value: "4" # Credit card payment method
        },
        PaymentRefNum: payment.stripe_payment_intent_id,
        TxnDate: payment.created_at.strftime("%Y-%m-%d"),
        PrivateNote: "Online payment for booking ##{payment.booking.confirmation_code}"
      }
    end

    def build_xero_payment_data
      bank_account = @integration.account_for('bank_deposits') || '090' # Default bank account

      {
        Date: payment.created_at.strftime("%Y-%m-%d"),
        Amount: payment.amount.to_f,
        Reference: payment.stripe_payment_intent_id,
        Account: {
          Code: bank_account
        },
        Contact: {
          Name: customer_name
        },
        Details: "Online payment for booking ##{payment.booking.confirmation_code}"
      }
    end

    def customer_name
      payment.booking.user.full_name.presence || payment.booking.user.email
    end
  end
end
