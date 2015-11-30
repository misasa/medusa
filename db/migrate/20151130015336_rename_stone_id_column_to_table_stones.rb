class RenameStoneIdColumnToTableStones < ActiveRecord::Migration
  def change
    rename_column :table_stones, :stone_id, :specimen_id
  end
end
