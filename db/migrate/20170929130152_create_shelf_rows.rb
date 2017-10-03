class CreateShelfRows < ActiveRecord::Migration[5.1]
  def change
    create_table :shelf_rows, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.jsonb :segment_lengths, null: false
      t.integer :levels, null: false
      t.integer :row_length, null: false
      t.integer :row_width, null: false
      t.float :right_front_x, null: false
      t.float :right_front_y, null: false
      t.string :orientation, null: false
    end
    add_index :shelf_rows, :name, unique: true
    add_reference :shelf_rows, :floor, type: :uuid, null: false
    add_foreign_key :shelf_rows, :floors, on_update: :cascade, on_delete: :cascade
  end
end
