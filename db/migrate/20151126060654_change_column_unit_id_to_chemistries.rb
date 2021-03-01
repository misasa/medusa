class ChangeColumnUnitIdToChemistries < ActiveRecord::Migration[4.2]
  def up
    change_column :chemistries, :unit_id, :integer, null: false
  end
  
  def down
    change_column :chemistries, :unit_id, :integer, null: true
  end
end
