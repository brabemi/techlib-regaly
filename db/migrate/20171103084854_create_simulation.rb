class CreateSimulation < ActiveRecord::Migration[5.0]
  def change
    create_table :simulations, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :name, null: false
      t.integer :volume_width, null: false
      t.jsonb :shelfs, null: false
      t.jsonb :books, null: false
    end
  end
end
