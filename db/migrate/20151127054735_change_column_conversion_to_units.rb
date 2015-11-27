class ChangeColumnConversionToUnits < ActiveRecord::Migration
  def up
    change_column :units, :conversion, :float
  end
  
  def down
    change_column :units, :conversion, :integer
  end


end
