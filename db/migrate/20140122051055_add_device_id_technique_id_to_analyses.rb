class AddDeviceIdTechniqueIdToAnalyses < ActiveRecord::Migration
  def change
    add_column :analyses, :technique_id, :integer
    add_column :analyses, :device_id, :integer
  end
end