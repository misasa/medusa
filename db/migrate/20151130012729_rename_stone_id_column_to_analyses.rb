class RenameStoneIdColumnToAnalyses < ActiveRecord::Migration
  def change
    rename_column :analyses, :stone_id, :specimen_id
  end
end
