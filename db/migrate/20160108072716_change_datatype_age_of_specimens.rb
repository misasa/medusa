class ChangeDatatypeAgeOfSpecimens < ActiveRecord::Migration[4.2]
  def change
    change_column :specimens, :age_min, :float
    change_column :specimens, :age_max, :float
  end
end
