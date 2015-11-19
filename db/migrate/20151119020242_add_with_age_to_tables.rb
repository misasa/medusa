class AddWithAgeToTables < ActiveRecord::Migration
  def change
    add_column :tables, :with_age, :boolean
  end
end
