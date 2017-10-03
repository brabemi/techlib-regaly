class CreateSignatures < ActiveRecord::Migration[5.1]
  def change
    create_table :signatures, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.string :signature, null: false
    end
    add_index :signatures, :signature, unique: true
  end
end
