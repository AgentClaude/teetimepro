class AccountingSyncJob < ApplicationJob
  queue_as :default

  # Sync accounting data for an organization
  # Can sync all data or specific types
  def perform(organization_id, sync_type: nil, force: false)
    organization = Organization.find(organization_id)
    integration = organization.accounting_integrations.connected.first
    
    return unless integration

    Rails.logger.info "Starting accounting sync for organization #{organization.name}"

    case sync_type
    when 'invoices'
      sync_invoices(organization, integration, force)
    when 'payments'
      sync_payments(organization, integration, force)
    when 'refunds'
      sync_refunds(organization, integration, force)
    else
      # Sync all types
      sync_invoices(organization, integration, force)
      sync_payments(organization, integration, force)
      sync_refunds(organization, integration, force)
    end

    integration.mark_synced!
    Rails.logger.info "Completed accounting sync for organization #{organization.name}"
  rescue => e
    Rails.logger.error "Accounting sync failed for organization #{organization_id}: #{e.message}"
    integration&.mark_error!(e.message)
    raise
  end

  private

  def sync_invoices(organization, integration, force)
    # Find bookings that need invoice sync
    bookings = if force
                 organization.bookings.confirmed.includes(:user, :tee_time)
               else
                 organization.bookings.confirmed
                           .left_joins(:accounting_syncs)
                           .where(
                             'accounting_syncs.id IS NULL OR ' \
                             '(accounting_syncs.sync_type = ? AND accounting_syncs.status = ?)',
                             'invoice', AccountingSync.statuses[:failed]
                           )
                           .includes(:user, :tee_time)
               end

    bookings.find_each do |booking|
      next if synced_recently?(booking, 'invoice') && !force
      
      Accounting::SyncInvoicesService.call(booking: booking)
      sleep(0.5) # Rate limiting
    end
  end

  def sync_payments(organization, integration, force)
    # Find completed payments that need sync
    payments = if force
                 Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: organization.id })
                       .completed
                       .includes(booking: :user)
               else
                 Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: organization.id })
                       .completed
                       .left_joins(:accounting_syncs)
                       .where(
                         'accounting_syncs.id IS NULL OR ' \
                         '(accounting_syncs.sync_type = ? AND accounting_syncs.status = ?)',
                         'payment', AccountingSync.statuses[:failed]
                       )
                       .includes(booking: :user)
               end

    payments.find_each do |payment|
      next if synced_recently?(payment, 'payment') && !force
      
      Accounting::SyncPaymentsService.call(payment: payment)
      sleep(0.5) # Rate limiting
    end
  end

  def sync_refunds(organization, integration, force)
    # Find refunded payments that need sync
    payments = if force
                 Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: organization.id })
                       .where.not(status: :completed)
                       .where('refund_amount_cents > 0')
                       .includes(booking: :user)
               else
                 Payment.joins(booking: { tee_time: { tee_sheet: :course } })
                       .where(courses: { organization_id: organization.id })
                       .where.not(status: :completed)
                       .where('refund_amount_cents > 0')
                       .left_joins(:accounting_syncs)
                       .where(
                         'accounting_syncs.id IS NULL OR ' \
                         '(accounting_syncs.sync_type = ? AND accounting_syncs.status = ?)',
                         'refund', AccountingSync.statuses[:failed]
                       )
                       .includes(booking: :user)
               end

    payments.find_each do |payment|
      next if synced_recently?(payment, 'refund') && !force
      
      refund_amount = Money.new(payment.refund_amount_cents)
      Accounting::SyncRefundsService.call(payment: payment, refund_amount: refund_amount)
      sleep(0.5) # Rate limiting
    end
  end

  def synced_recently?(record, sync_type)
    record.accounting_syncs
          .where(sync_type: sync_type, status: :completed)
          .where('completed_at > ?', 1.hour.ago)
          .exists?
  end
end
