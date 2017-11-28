class CreateSignatures < ActiveRecord::Migration[5.0]
  def change
    create_table :signatures, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :signature, null: false
      t.string :signature_prefix, null: false
      t.integer :signature_number, null: false
      t.integer :year_min, null: false
      t.integer :year_max, null: false
      t.integer :volumes_total, null: false
      t.json :volumes, null: false
    end
    add_index :signatures, :signature, unique: true
  end
end
