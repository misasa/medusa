class RenameStoneTypeColumnToStones < ActiveRecord::Migration
  def change
    rename_column :stones, :stone_type, :specimen_type
  end
end
