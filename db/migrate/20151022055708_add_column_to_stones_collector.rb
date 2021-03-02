class AddColumnToStonesCollector < ActiveRecord::Migration[4.2]
  def change
    change_table :stones do |t|
      t.string :collector
      t.string :collector_detail
    end
  end
end
