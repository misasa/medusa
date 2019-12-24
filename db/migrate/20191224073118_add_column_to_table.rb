class AddColumnToTable < ActiveRecord::Migration
  def change
    add_column :tables, :data, :text
  end
end
