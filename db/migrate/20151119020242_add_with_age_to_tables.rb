class AddWithAgeToTables < ActiveRecord::Migration[4.2]
  def change
    add_column :tables, :with_age, :boolean
  end
end
