# frozen_string_literal: true

class CreateTeeTimeBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :tee_time_blocks do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.integer :block_type, null: false, default: 0 # maintenance, event, weather, other
      t.string :reason, null: false
      t.text :description
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.boolean :recurring, default: false, null: false
      t.string :recurrence_pattern # weekly, daily, etc.
      t.boolean :active, default: true, null: false
      t.integer :affected_tee_time_count, default: 0, null: false

      t.timestamps
    end

    add_index :tee_time_blocks, [:course_id, :starts_at, :ends_at]
    add_index :tee_time_blocks, :active

    # Track which block affected each tee time
    add_reference :tee_times, :tee_time_block, null: true, foreign_key: { on_delete: :nullify }
    add_column :tee_times, :previous_status, :integer, null: true
  end
end
