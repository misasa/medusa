class AddColumnToTable < ActiveRecord::Migration[4.2]
  def change
    add_column :tables, :data, :text
  end
end
