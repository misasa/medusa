class AddWithErrorToTable < ActiveRecord::Migration[4.2]
  def change
    add_column :tables, :with_error, :boolean, default: true, null: false
  end
end
