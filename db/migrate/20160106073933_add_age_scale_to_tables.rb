class AddAgeScaleToTables < ActiveRecord::Migration
  def change
    add_column :tables, :age_scale, :integer
  end
end
