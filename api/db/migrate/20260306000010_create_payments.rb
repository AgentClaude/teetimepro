class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: { on_delete: :cascade }
      t.string :stripe_payment_intent_id
      t.integer :amount_cents, null: false
      t.string :amount_currency, default: "USD", null: false
      t.integer :refund_amount_cents
      t.string :refund_amount_currency
      t.integer :status, default: 0, null: false
      t.string :stripe_charge_id
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, :stripe_payment_intent_id, unique: true
    add_index :payments, :status
  end
end
