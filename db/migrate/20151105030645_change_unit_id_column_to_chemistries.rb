class ChangeUnitIdColumnToChemistries < ActiveRecord::Migration
  def up
    change_column :chemistries, :unit_id, :integer, null: true
  end
  
  def down
    change_column :chemistries, :unit_id, :integer, null: false
  end
end
