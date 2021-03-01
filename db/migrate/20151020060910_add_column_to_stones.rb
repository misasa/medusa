class AddColumnToStones < ActiveRecord::Migration[4.2]
  def change
    change_table :stones do |t|
      t.string   :igsn, limit: 9, unique: true
      t.integer  :age_min
      t.integer  :age_max
      t.string   :age_unit
      t.integer  :size
      t.string   :size_unit
      t.datetime :collected_at
      t.string   :collection_date_precision
    end
  end
end
