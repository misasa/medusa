class RenameStoneCustomAttributesToSpecimenCustomAttributes < ActiveRecord::Migration
  def change
    rename_table :stone_custom_attributes, :specimen_custom_attributes
  end
end
