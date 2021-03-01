class RenameTableStonesToTableSpecimens < ActiveRecord::Migration[4.2]
  def change
    rename_table :table_stones, :table_specimens
  end
end
