class AddAbsAgeToSpecimens < ActiveRecord::Migration
  def change
    change_table :specimens do |t|
      t.integer :abs_age, limit: 8, comment: "絶対年代"
    end
  end
end
