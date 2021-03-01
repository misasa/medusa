class AddDeviceIdTechniqueIdToAnalyses < ActiveRecord::Migration[4.2]
  def change
    add_column :analyses, :technique_id, :integer
    add_column :analyses, :device_id, :integer
  end
end