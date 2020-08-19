class AddWithErrorToTable < ActiveRecord::Migration
  def change
    add_column :tables, :with_error, :boolean, default: true, null: false
  end
end
