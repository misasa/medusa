class RenameTableStonesToTableSpecimens < ActiveRecord::Migration
  def change
    rename_table :table_stones, :table_specimens
  end
end
