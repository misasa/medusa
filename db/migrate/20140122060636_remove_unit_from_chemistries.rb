class RemoveUnitFromChemistries < ActiveRecord::Migration
  def self.up
    remove_column :chemistries, :unit, :string
  end
  
  def self.down
    add_column :chemistries, :unit, :string
  end
end
