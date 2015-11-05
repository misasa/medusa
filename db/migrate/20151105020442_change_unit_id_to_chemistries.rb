class ChangeUnitIdToChemistries < ActiveRecord::Migration
  def up
    change_column :chemistries, :unit_id, :integer, null: false
  end
  
  def down
    change_column :chemistries, :unit_id, :integer, null: true
  end
end
