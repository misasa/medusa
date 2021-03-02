class RenameStoneIdColumnToAnalyses < ActiveRecord::Migration[4.2]
  def change
    rename_column :analyses, :stone_id, :specimen_id
  end
end
