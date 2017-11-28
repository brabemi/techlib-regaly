class CreateShelfRows < ActiveRecord::Migration[5.0]
  def change
    create_table :shelf_rows, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.json :segment_lengths, null: false
      t.integer :levels, null: false
      t.integer :row_length, null: false
      t.boolean :enabled, null: false
    end
    add_reference :shelf_rows, :floor_section, type: :uuid, null: false
    add_foreign_key :shelf_rows, :floor_sections, on_update: :cascade, on_delete: :cascade
    add_index :shelf_rows, [:floor_section_id, :name], unique: true
  end
end
