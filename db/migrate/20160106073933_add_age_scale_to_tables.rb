class AddAgeScaleToTables < ActiveRecord::Migration[4.2]
  def change
    add_column :tables, :age_scale, :integer
  end
end
