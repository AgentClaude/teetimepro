class EnhancePaymentsForStatusTracking < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      change_table :payments do |t|
        t.references :organization, null: true, foreign_key: { on_delete: :cascade }
        t.references :user, null: true, foreign_key: { on_delete: :nullify }
        t.integer :payment_method, default: 0, null: false
        t.integer :provider, default: 0, null: false
        t.string :provider_transaction_id
        t.string :refund_reason
        t.datetime :paid_at
        t.datetime :refunded_at
      end

      add_index :payments, :provider_transaction_id
      add_index :payments, :payment_method
      add_index :payments, :provider
      add_index :payments, [:booking_id, :status], name: "index_payments_on_booking_status"
    end
  end
end
