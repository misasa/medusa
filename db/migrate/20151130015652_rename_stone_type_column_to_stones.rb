class RenameStoneTypeColumnToStones < ActiveRecord::Migration[4.2]
  def change
    rename_column :stones, :stone_type, :specimen_type
  end
end
