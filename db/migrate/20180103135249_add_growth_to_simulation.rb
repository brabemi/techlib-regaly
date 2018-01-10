class AddGrowthToSimulation < ActiveRecord::Migration[5.0]
  def change
    add_column :signatures, :growth, :integer, null: false, default: 0
  end
end
