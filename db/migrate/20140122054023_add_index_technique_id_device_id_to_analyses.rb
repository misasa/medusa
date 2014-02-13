class AddIndexTechniqueIdDeviceIdToAnalyses < ActiveRecord::Migration
  def change
    add_index :analyses, :technique_id
    add_index :analyses, :device_id
  end
end
