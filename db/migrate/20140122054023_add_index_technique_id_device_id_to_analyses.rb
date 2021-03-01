class AddIndexTechniqueIdDeviceIdToAnalyses < ActiveRecord::Migration[4.2]
  def change
    add_index :analyses, :technique_id
    add_index :analyses, :device_id
  end
end
