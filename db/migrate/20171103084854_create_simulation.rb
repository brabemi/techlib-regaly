class CreateSimulation < ActiveRecord::Migration[5.0]
  def change
    create_table :simulations, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.integer :volume_width, null: false
      t.json :shelfs, null: false
      t.json :books, null: false
    end
  end
end
