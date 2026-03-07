class CreateGolferSegments < ActiveRecord::Migration[8.0]
  def change
    create_table :golfer_segments do |t|
      t.references :organization, null: false, foreign_key: { on_delete: :cascade }
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.text :description
      t.jsonb :filter_criteria, null: false, default: {}
      t.boolean :is_dynamic, null: false, default: true
      t.integer :cached_count, null: false, default: 0
      t.datetime :last_evaluated_at

      t.timestamps
    end

    add_index :golfer_segments, [:organization_id, :name], unique: true
    add_index :golfer_segments, :filter_criteria, using: :gin

    # Join table for static segment membership
    create_table :golfer_segment_memberships do |t|
      t.references :golfer_segment, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :golfer_segment_memberships, [:golfer_segment_id, :user_id], unique: true,
              name: "idx_segment_memberships_unique"
  end
end
