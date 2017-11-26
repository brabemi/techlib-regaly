class CreateFloorSections < ActiveRecord::Migration[5.0]
  def change
    create_table :floor_sections, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :floor, null: false
      t.string :name, null: false
    end
    add_index :floor_sections, :name, unique: true
  end
end
