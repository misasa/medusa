class RenameStoneIdColumnToTableAnalyses < ActiveRecord::Migration
  def change
    rename_column :table_analyses, :stone_id, :specimen_id
  end
end
