class RenameStoneCustomAttributesToSpecimenCustomAttributes < ActiveRecord::Migration[4.2]
  def change
    rename_table :stone_custom_attributes, :specimen_custom_attributes
  end
end
