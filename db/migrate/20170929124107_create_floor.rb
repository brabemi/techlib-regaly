class CreateFloor < ActiveRecord::Migration[5.0]
  def change
    create_table :floors, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :floor, null: false
      t.integer :width, null: false
      t.integer :height, null: false
    end
    add_index :floors, :floor, unique: true
  end
end
