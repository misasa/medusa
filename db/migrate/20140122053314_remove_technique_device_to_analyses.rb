class RemoveTechniqueDeviceToAnalyses < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :analyses, :technique
    remove_column :analyses, :device
  end
  
  def self.down
    add_column :analyses, :technique, :string
    add_column :analyses, :device, :string
  end
end
