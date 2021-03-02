class RenameStoneIdColumnToTableAnalyses < ActiveRecord::Migration[4.2]
  def change
    rename_column :table_analyses, :stone_id, :specimen_id
  end
end
