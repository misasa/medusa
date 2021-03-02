class RemoveUnitFromChemistries < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :chemistries, :unit, :string
  end
  
  def self.down
    add_column :chemistries, :unit, :string
  end
end
