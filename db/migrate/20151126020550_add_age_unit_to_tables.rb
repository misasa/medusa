class AddAgeUnitToTables < ActiveRecord::Migration[4.2]
  def change
    add_column :tables, :age_unit, :string
  end
end
