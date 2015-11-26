class AddAgeUnitToTables < ActiveRecord::Migration
  def change
    add_column :tables, :age_unit, :string
  end
end
