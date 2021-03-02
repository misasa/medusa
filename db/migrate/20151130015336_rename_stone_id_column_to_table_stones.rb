class RenameStoneIdColumnToTableStones < ActiveRecord::Migration[4.2]
  def change
    rename_column :table_stones, :stone_id, :specimen_id
  end
end
