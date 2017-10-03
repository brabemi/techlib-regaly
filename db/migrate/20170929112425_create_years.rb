class CreateYears < ActiveRecord::Migration[5.1]
  def change
    create_table :years, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.integer :year, null: false
      t.integer :volumes, null: false
    end
    add_reference :years, :signature, type: :uuid, null: false
    add_foreign_key :years, :signatures, on_update: :cascade, on_delete: :cascade
    add_index :years, [:signature_id, :year], unique: true
  end
end
