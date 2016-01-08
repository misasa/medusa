class ChangeDatatypeAgeOfSpecimens < ActiveRecord::Migration
  def change
    change_column :specimens, :age_min, :float
    change_column :specimens, :age_max, :float
  end
end
