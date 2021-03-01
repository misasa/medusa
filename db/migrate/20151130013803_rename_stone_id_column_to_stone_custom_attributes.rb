class RenameStoneIdColumnToStoneCustomAttributes < ActiveRecord::Migration[4.2]
  def change
    rename_column :stone_custom_attributes, :stone_id, :specimen_id
  end
end
